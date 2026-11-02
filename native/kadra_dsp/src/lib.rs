//! Kadra DSP: the audio editor's waveform, analyzers and effects in Rust,
//! called from Dart through a plain C ABI (`lib/features/audio_editor/engine/native_dsp.dart`).
//!
//! Conventions: paths are UTF-8; audio is planar (`channels` arrays of
//! `len` floats, laid out one after another); return values below zero are
//! errors: -1 I/O, -2 not a supported WAV, -3 bad arguments, -4 internal
//! error. Functions that fill a caller buffer of `cap` items return how many
//! items there are; if that is more than `cap`, call again with a bigger one.

#![allow(clippy::missing_safety_doc)]

pub mod dsp;
pub mod wav;

use std::ffi::{c_char, CStr};
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::slice;

use wav::WavError;

const E_IO: i64 = -1;
const E_FORMAT: i64 = -2;
const E_ARGS: i64 = -3;
const E_PANIC: i64 = -4;

fn guard<F: FnOnce() -> i64>(f: F) -> i64 {
    catch_unwind(AssertUnwindSafe(f)).unwrap_or(E_PANIC)
}

fn err(e: WavError) -> i64 {
    match e {
        WavError::Io(_) => E_IO,
        WavError::Format(_) => E_FORMAT,
    }
}

unsafe fn path<'a>(p: *const c_char) -> Option<&'a str> {
    if p.is_null() {
        return None;
    }
    CStr::from_ptr(p).to_str().ok()
}

fn end_opt(end: i64) -> Option<u64> {
    if end < 0 {
        None
    } else {
        Some(end as u64)
    }
}

unsafe fn planar<'a>(data: *const f32, channels: i64, len: i64) -> Option<Vec<&'a [f32]>> {
    if data.is_null() || channels <= 0 || len < 0 {
        return None;
    }
    let all = slice::from_raw_parts(data, (channels * len) as usize);
    Some(all.chunks(len.max(1) as usize).take(channels as usize).collect())
}

unsafe fn write_planar(out: *mut f32, chans: &[Vec<f32>], len: usize) {
    for (c, ch) in chans.iter().enumerate() {
        let dst = slice::from_raw_parts_mut(out.add(c * len), len);
        dst.copy_from_slice(&ch[..len]);
    }
}

/// Library version (to detect a stale DLL next to a newer app).
#[no_mangle]
pub extern "C" fn kd_version() -> i64 {
    1
}

/// WAV header: `out` = [sample_rate, channels, frames].
#[no_mangle]
pub unsafe extern "C" fn kd_wav_info(p: *const c_char, out: *mut i64) -> i64 {
    guard(|| {
        let (Some(p), false) = (path(p), out.is_null()) else { return E_ARGS };
        let mut f = match std::fs::File::open(p) {
            Ok(f) => f,
            Err(_) => return E_IO,
        };
        match wav::read_info(&mut f) {
            Ok(i) => {
                let o = slice::from_raw_parts_mut(out, 3);
                o[0] = i.sample_rate as i64;
                o[1] = i.channels as i64;
                o[2] = i.frames() as i64;
                0
            }
            Err(e) => err(e),
        }
    })
}

/// Waveform min/max per `bucket` frames into planar `mins`/`maxs`
/// (`channels * cap` floats each). Returns the number of buckets.
#[no_mangle]
pub unsafe extern "C" fn kd_peaks(p: *const c_char, bucket: i64, mins: *mut f32, maxs: *mut f32, cap: i64) -> i64 {
    guard(|| {
        let Some(p) = path(p) else { return E_ARGS };
        if bucket <= 0 || mins.is_null() || maxs.is_null() {
            return E_ARGS;
        }
        match dsp::peaks(p, bucket as usize) {
            Ok((_, mn, mx)) => {
                let n = mn.first().map_or(0, |c| c.len());
                if n as i64 <= cap {
                    write_planar(mins, &mn, n);
                    write_planar(maxs, &mx, n);
                }
                n as i64
            }
            Err(e) => err(e),
        }
    })
}

/// Per-channel stats into `out` (`channels` × [`dsp::ChannelStats`]).
/// Returns the channel count.
#[no_mangle]
pub unsafe extern "C" fn kd_stats(
    p: *const c_char,
    start: i64,
    end: i64,
    clip_level: f64,
    out: *mut dsp::ChannelStats,
    cap: i64,
) -> i64 {
    guard(|| {
        let Some(p) = path(p) else { return E_ARGS };
        match dsp::stats(p, start.max(0) as u64, end_opt(end), clip_level) {
            Ok(st) => {
                if !out.is_null() && st.len() as i64 <= cap {
                    slice::from_raw_parts_mut(out, st.len()).copy_from_slice(&st);
                }
                st.len() as i64
            }
            Err(e) => err(e),
        }
    })
}

/// Average spectrum in dB, `fft_size / 2 + 1` values.
#[no_mangle]
pub unsafe extern "C" fn kd_spectrum(p: *const c_char, start: i64, end: i64, fft_size: i64, out: *mut f64) -> i64 {
    guard(|| {
        let Some(p) = path(p) else { return E_ARGS };
        if out.is_null() || fft_size < 2 || (fft_size & (fft_size - 1)) != 0 {
            return E_ARGS;
        }
        match dsp::spectrum(p, start.max(0) as u64, end_opt(end), fft_size as usize) {
            Ok(v) => {
                slice::from_raw_parts_mut(out, v.len()).copy_from_slice(&v);
                v.len() as i64
            }
            Err(e) => err(e),
        }
    })
}

/// Short-term RMS envelope in dB. Returns the number of windows.
#[no_mangle]
pub unsafe extern "C" fn kd_rms_envelope(
    p: *const c_char,
    window_ms: i64,
    start: i64,
    end: i64,
    out: *mut f64,
    cap: i64,
) -> i64 {
    guard(|| {
        let Some(p) = path(p) else { return E_ARGS };
        match dsp::rms_envelope(p, window_ms.max(1) as u32, start.max(0) as u64, end_opt(end)) {
            Ok((_, v)) => {
                if !out.is_null() && v.len() as i64 <= cap {
                    slice::from_raw_parts_mut(out, v.len()).copy_from_slice(&v);
                }
                v.len() as i64
            }
            Err(e) => err(e),
        }
    })
}

/// Clipped runs as (start, end) frame pairs. Returns the number of runs.
#[no_mangle]
pub unsafe extern "C" fn kd_find_clipping(p: *const c_char, level: f64, min_run: i64, out: *mut i64, cap: i64) -> i64 {
    guard(|| {
        let Some(p) = path(p) else { return E_ARGS };
        match dsp::find_clipping(p, level, min_run.max(0) as u64) {
            Ok(v) => {
                if !out.is_null() && v.len() as i64 <= cap {
                    let o = slice::from_raw_parts_mut(out, v.len() * 2);
                    for (k, (a, b)) in v.iter().enumerate() {
                        o[2 * k] = *a as i64;
                        o[2 * k + 1] = *b as i64;
                    }
                }
                v.len() as i64
            }
            Err(e) => err(e),
        }
    })
}

#[no_mangle]
pub extern "C" fn kd_paulstretch_len(len: i64, stretch: f64) -> i64 {
    dsp::paulstretch_len(len.max(0) as usize, stretch) as i64
}

/// `out` holds `channels * kd_paulstretch_len(len, stretch)` floats.
#[no_mangle]
pub unsafe extern "C" fn kd_paulstretch(
    input: *const f32,
    channels: i64,
    len: i64,
    sample_rate: i64,
    stretch: f64,
    window_sec: f64,
    out: *mut f32,
) -> i64 {
    guard(|| {
        let Some(inp) = planar(input, channels, len) else { return E_ARGS };
        if out.is_null() || !(stretch > 0.0) || sample_rate <= 0 {
            return E_ARGS;
        }
        let res = dsp::paulstretch(&inp, sample_rate as u32, stretch, window_sec);
        let n = res.first().map_or(0, |c| c.len());
        write_planar(out, &res, n);
        n as i64
    })
}

/// `out` holds `channels * len` floats.
#[no_mangle]
pub unsafe extern "C" fn kd_wahwah(
    input: *const f32,
    channels: i64,
    len: i64,
    sample_rate: i64,
    lfo_hz: f64,
    depth: f64,
    resonance: f64,
    offset: f64,
    out: *mut f32,
) -> i64 {
    guard(|| {
        let Some(inp) = planar(input, channels, len) else { return E_ARGS };
        if out.is_null() || sample_rate <= 0 {
            return E_ARGS;
        }
        let res = dsp::wahwah(&inp, sample_rate as u32, lfo_hz, depth, resonance, offset);
        write_planar(out, &res, len as usize);
        len
    })
}

#[no_mangle]
pub extern "C" fn kd_sliding_speed_len(len: i64, from_pct: f64, to_pct: f64) -> i64 {
    dsp::sliding_speed_len(len.max(0) as usize, from_pct, to_pct) as i64
}

/// `out` holds `channels * kd_sliding_speed_len(len, from, to)` floats.
#[no_mangle]
pub unsafe extern "C" fn kd_sliding_speed(
    input: *const f32,
    channels: i64,
    len: i64,
    from_pct: f64,
    to_pct: f64,
    out: *mut f32,
) -> i64 {
    guard(|| {
        let Some(inp) = planar(input, channels, len) else { return E_ARGS };
        if out.is_null() || len < 2 {
            return E_ARGS;
        }
        let res = dsp::sliding_speed(&inp, from_pct, to_pct);
        let n = res.first().map_or(0, |c| c.len());
        write_planar(out, &res, n);
        n as i64
    })
}

#[cfg(test)]
mod tests {
    use super::dsp::*;

    #[test]
    fn fft_roundtrip() {
        let mut re: Vec<f64> = (0..64).map(|i| (i as f64 * 0.3).sin()).collect();
        let orig = re.clone();
        let mut im = vec![0.0; 64];
        fft(&mut re, &mut im, false);
        fft(&mut re, &mut im, true);
        for (a, b) in re.iter().zip(&orig) {
            assert!((a - b).abs() < 1e-12);
        }
    }

    #[test]
    fn sliding_and_stretch_lengths() {
        let x: Vec<f32> = (0..48000).map(|i| (i as f32 * 0.05).sin() * 0.5).collect();
        let out = sliding_speed(&[&x], 0.0, 100.0);
        assert_eq!(out[0].len(), sliding_speed_len(x.len(), 0.0, 100.0));
        assert!(out[0].len() < x.len());
        let st = paulstretch(&[&x], 48000, 2.0, 0.1);
        assert_eq!(st[0].len(), 96000);
        let rms = |v: &[f32]| (v.iter().map(|&s| (s as f64).powi(2)).sum::<f64>() / v.len() as f64).sqrt();
        assert!((rms(&st[0]) - rms(&x)).abs() < 1e-3);
    }
}
