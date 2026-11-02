//! RIFF/WAVE reader matching `lib/features/audio_editor/engine/wav.dart`:
//! 32/64-bit float and 8/16/24/32-bit integer PCM, WAVE_FORMAT_EXTENSIBLE,
//! RF64 and `data` chunks of unknown size.

use std::fs::File;
use std::io::{self, Read, Seek, SeekFrom};

#[derive(Clone, Copy, Debug)]
pub struct WavInfo {
    pub sample_rate: u32,
    pub channels: usize,
    pub bits_per_sample: usize,
    pub is_float: bool,
    pub data_offset: u64,
    pub data_length: u64,
}

impl WavInfo {
    pub fn bytes_per_frame(&self) -> usize {
        self.channels * self.bits_per_sample / 8
    }
    pub fn frames(&self) -> u64 {
        let b = self.bytes_per_frame() as u64;
        if b == 0 {
            0
        } else {
            self.data_length / b
        }
    }
}

#[derive(Debug)]
pub enum WavError {
    Io(io::Error),
    Format(&'static str),
}

impl From<io::Error> for WavError {
    fn from(e: io::Error) -> Self {
        WavError::Io(e)
    }
}

fn u16le(b: &[u8], o: usize) -> u16 {
    u16::from_le_bytes([b[o], b[o + 1]])
}
fn u32le(b: &[u8], o: usize) -> u32 {
    u32::from_le_bytes([b[o], b[o + 1], b[o + 2], b[o + 3]])
}

fn read_at(f: &mut File, pos: u64, len: usize) -> io::Result<Vec<u8>> {
    f.seek(SeekFrom::Start(pos))?;
    let mut buf = Vec::with_capacity(len);
    f.by_ref().take(len as u64).read_to_end(&mut buf)?;
    Ok(buf)
}

pub fn read_info(f: &mut File) -> Result<WavInfo, WavError> {
    let file_len = f.metadata()?.len();
    let head = read_at(f, 0, 12)?;
    if head.len() < 12 || (&head[0..4] != b"RIFF" && &head[0..4] != b"RF64") || &head[8..12] != b"WAVE" {
        return Err(WavError::Format("Not a WAV file"));
    }
    let (mut rate, mut ch, mut bits) = (None, None, None);
    let mut is_float = false;
    let mut ds64_data: Option<u64> = None;
    let mut pos: u64 = 12;
    while pos + 8 <= file_len {
        let h = read_at(f, pos, 8)?;
        if h.len() < 8 {
            break;
        }
        let id = &h[0..4];
        let size = u32le(&h, 4) as u64;
        if id == b"ds64" {
            let b = read_at(f, pos + 8, size.min(28) as usize)?;
            if b.len() >= 16 {
                ds64_data = Some(u64::from_le_bytes(b[8..16].try_into().unwrap()));
            }
        } else if id == b"fmt " {
            let b = read_at(f, pos + 8, size as usize)?;
            if b.len() < 16 {
                return Err(WavError::Format("short fmt chunk"));
            }
            let tag = u16le(&b, 0);
            ch = Some(u16le(&b, 2) as usize);
            rate = Some(u32le(&b, 4));
            bits = Some(u16le(&b, 14) as usize);
            let mut format = tag;
            if tag == 0xFFFE && size >= 26 && b.len() >= 26 {
                format = u16le(&b, 24);
            }
            is_float = format == 3;
        } else if id == b"data" {
            let mut len = size;
            if let Some(d) = ds64_data {
                if size == 0xFFFF_FFFF {
                    len = d;
                }
            }
            if size == 0xFFFF_FFFF || size == 0 || pos + 8 + len > file_len {
                len = file_len - pos - 8;
            }
            let (Some(rate), Some(ch), Some(bits)) = (rate, ch, bits) else {
                return Err(WavError::Format("WAV without fmt chunk"));
            };
            if ch == 0 || bits == 0 || bits % 8 != 0 {
                return Err(WavError::Format("unsupported WAV format"));
            }
            return Ok(WavInfo {
                sample_rate: rate,
                channels: ch,
                bits_per_sample: bits,
                is_float,
                data_offset: pos + 8,
                data_length: len,
            });
        }
        pos += 8 + size + (size & 1);
    }
    Err(WavError::Format("WAV without data chunk"))
}

/// Decodes interleaved PCM into planar channels (`out[c][offset + i]`).
pub fn decode_into(bytes: &[u8], info: &WavInfo, out: &mut [Vec<f32>], offset: usize) {
    let ch = info.channels;
    let bps = info.bits_per_sample / 8;
    let frames = bytes.len() / info.bytes_per_frame();
    for i in 0..frames {
        for (c, dst) in out.iter_mut().enumerate().take(ch) {
            let o = (i * ch + c) * bps;
            let v: f32 = if info.is_float && bps == 4 {
                f32::from_le_bytes(bytes[o..o + 4].try_into().unwrap())
            } else if info.is_float && bps == 8 {
                f64::from_le_bytes(bytes[o..o + 8].try_into().unwrap()) as f32
            } else if bps == 2 {
                (i16::from_le_bytes([bytes[o], bytes[o + 1]]) as f64 / 32768.0) as f32
            } else if bps == 3 {
                let mut x = (bytes[o] as i32) | ((bytes[o + 1] as i32) << 8) | ((bytes[o + 2] as i32) << 16);
                if x & 0x80_0000 != 0 {
                    x -= 0x100_0000;
                }
                (x as f64 / 8_388_608.0) as f32
            } else if bps == 4 {
                (i32::from_le_bytes(bytes[o..o + 4].try_into().unwrap()) as f64 / 2_147_483_648.0) as f32
            } else {
                ((bytes[o] as f64 - 128.0) / 128.0) as f32
            };
            dst[offset + i] = v;
        }
    }
}

/// Reads `count` frames at `start` as planar float channels.
pub fn read_frames(f: &mut File, info: &WavInfo, start: u64, count: u64) -> io::Result<Vec<Vec<f32>>> {
    let frames = info.frames();
    let s = start.min(frames);
    let n = count.min(frames - s) as usize;
    let mut out = vec![vec![0f32; n]; info.channels];
    if n == 0 {
        return Ok(out);
    }
    let bytes = read_at(f, info.data_offset + s * info.bytes_per_frame() as u64, n * info.bytes_per_frame())?;
    decode_into(&bytes, info, &mut out, 0);
    // A truncated file: the rest stays zero, like the Dart reader.
    Ok(out)
}

/// Calls `each` with consecutive blocks of `[start, end)`.
pub fn for_blocks<F: FnMut(&[Vec<f32>])>(
    f: &mut File,
    info: &WavInfo,
    start: u64,
    end: Option<u64>,
    block: u64,
    mut each: F,
) -> io::Result<()> {
    let stop = end.unwrap_or(info.frames()).min(info.frames());
    let mut s = start;
    while s < stop {
        let n = block.min(stop - s);
        let b = read_frames(f, info, s, n)?;
        each(&b);
        s += block;
    }
    Ok(())
}
