//! Ports of `lib/features/audio_editor/engine/dsp.dart` and `peaks.dart`.
//! The algorithms and the order of floating-point operations follow the
//! Dart code, so results match it (exactly for the analyzers; Paulstretch
//! uses its own random phases).

use std::f64::consts::PI;
use std::fs::File;

use crate::wav::{self, WavError, WavInfo};

// ------------------------------------------------------------------ FFT

/// In-place iterative radix-2 complex FFT (`re.len()` must be 2^k).
pub fn fft(re: &mut [f64], im: &mut [f64], inverse: bool) {
    let n = re.len();
    let mut j = 0usize;
    for i in 1..n {
        let mut bit = n >> 1;
        while j & bit != 0 {
            j ^= bit;
            bit >>= 1;
        }
        j ^= bit;
        if i < j {
            re.swap(i, j);
            im.swap(i, j);
        }
    }
    let mut len = 2;
    while len <= n {
        let ang = 2.0 * PI / len as f64 * if inverse { 1.0 } else { -1.0 };
        let (wr, wi) = (ang.cos(), ang.sin());
        let half = len / 2;
        let mut i = 0;
        while i < n {
            let (mut cr, mut ci) = (1.0f64, 0.0f64);
            for k in 0..half {
                let (a, b) = (i + k, i + k + half);
                let ar = re[b] * cr - im[b] * ci;
                let ai = re[b] * ci + im[b] * cr;
                re[b] = re[a] - ar;
                im[b] = im[a] - ai;
                re[a] += ar;
                im[a] += ai;
                let ncr = cr * wr - ci * wi;
                ci = cr * wi + ci * wr;
                cr = ncr;
            }
            i += len;
        }
        len <<= 1;
    }
    if inverse {
        let nf = n as f64;
        for i in 0..n {
            re[i] /= nf;
            im[i] /= nf;
        }
    }
}

pub fn next_pow2(n: usize) -> usize {
    let mut p = 1;
    while p < n {
        p <<= 1;
    }
    p
}

pub fn hann(n: usize) -> Vec<f64> {
    (0..n).map(|i| 0.5 - 0.5 * (2.0 * PI * i as f64 / n as f64).cos()).collect()
}

fn db(x: f64) -> f64 {
    20.0 * x.ln() / std::f64::consts::LN_10
}

// ------------------------------------------------------------------ waveform

/// Min/max per bucket, planar `[channel][bucket]`.
pub fn peaks(path: &str, bucket: usize) -> Result<(WavInfo, Vec<Vec<f32>>, Vec<Vec<f32>>), WavError> {
    let mut f = File::open(path)?;
    let info = wav::read_info(&mut f)?;
    let frames = info.frames() as usize;
    let n = frames.div_ceil(bucket);
    let mut mins = vec![vec![0f32; n]; info.channels];
    let mut maxs = vec![vec![0f32; n]; info.channels];
    let mut frame = 0usize;
    wav::for_blocks(&mut f, &info, 0, None, (bucket * 512) as u64, |block| {
        let len = block[0].len();
        for c in 0..info.channels {
            let d = &block[c];
            let mut i = 0;
            while i < len {
                let end = len.min(i + bucket);
                let (mut lo, mut hi) = (1e9f32, -1e9f32);
                for &v in &d[i..end] {
                    if v < lo {
                        lo = v;
                    }
                    if v > hi {
                        hi = v;
                    }
                }
                let b = (frame + i) / bucket;
                mins[c][b] = lo;
                maxs[c][b] = hi;
                i += bucket;
            }
        }
        frame += len;
    })?;
    Ok((info, mins, maxs))
}

// ------------------------------------------------------------------ analysis

#[repr(C)]
#[derive(Clone, Copy, Default, Debug)]
pub struct ChannelStats {
    pub peak: f64,
    pub rms: f64,
    pub dc: f64,
    pub min: f64,
    pub max: f64,
    pub clipped: i64,
}

pub fn stats(path: &str, start: u64, end: Option<u64>, clip_level: f64) -> Result<Vec<ChannelStats>, WavError> {
    let mut f = File::open(path)?;
    let info = wav::read_info(&mut f)?;
    let ch = info.channels;
    let (mut peak, mut sum, mut sq) = (vec![0f64; ch], vec![0f64; ch], vec![0f64; ch]);
    let (mut lo, mut hi) = (vec![0f64; ch], vec![0f64; ch]);
    let mut clip = vec![0i64; ch];
    let mut n = 0u64;
    wav::for_blocks(&mut f, &info, start, end, 65536, |block| {
        for c in 0..ch {
            for &s in &block[c] {
                let v = s as f64;
                let a = v.abs();
                if a > peak[c] {
                    peak[c] = a;
                }
                if v < lo[c] {
                    lo[c] = v;
                }
                if v > hi[c] {
                    hi[c] = v;
                }
                if a >= clip_level {
                    clip[c] += 1;
                }
                sum[c] += v;
                sq[c] += v * v;
            }
        }
        n += block[0].len() as u64;
    })?;
    let nf = n as f64;
    Ok((0..ch)
        .map(|c| ChannelStats {
            peak: peak[c],
            rms: if n == 0 { 0.0 } else { (sq[c] / nf).sqrt() },
            dc: if n == 0 { 0.0 } else { sum[c] / nf },
            min: lo[c],
            max: hi[c],
            clipped: clip[c],
        })
        .collect())
}

/// Average magnitude spectrum in dB (Hann, mono-summed), `fft_size/2 + 1` bins.
pub fn spectrum(path: &str, start: u64, end: Option<u64>, fft_size: usize) -> Result<Vec<f64>, WavError> {
    let mut f = File::open(path)?;
    let info = wav::read_info(&mut f)?;
    let stop = end.unwrap_or(info.frames()).min(info.frames());
    let w = hann(fft_size);
    let mut acc = vec![0f64; fft_size / 2 + 1];
    let (mut re, mut im) = (vec![0f64; fft_size], vec![0f64; fft_size]);
    let mut frames = 0u64;
    let span = stop.saturating_sub(start) as f64;
    let hop = ((fft_size / 2) as u64).max((span / 2000.0).floor() as u64);
    let mut s = start;
    while s + fft_size as u64 <= stop {
        let block = wav::read_frames(&mut f, &info, s, fft_size as u64)?;
        let chn = block.len() as f64;
        for i in 0..fft_size {
            let mut v = 0.0f64;
            for c in &block {
                v += c[i] as f64;
            }
            re[i] = v / chn * w[i];
            im[i] = 0.0;
        }
        fft(&mut re, &mut im, false);
        for (i, a) in acc.iter_mut().enumerate() {
            *a += (re[i] * re[i] + im[i] * im[i]).sqrt();
        }
        frames += 1;
        s += hop;
    }
    let norm = if frames == 0 { 1.0 } else { frames as f64 * fft_size as f64 / 4.0 };
    Ok(acc.iter().map(|&a| if a <= 0.0 { -120.0 } else { (-120.0f64).max(db(a / norm)) }).collect())
}

/// Short-term RMS (dB) of the loudest channel in windows of `window_ms`.
pub fn rms_envelope(path: &str, window_ms: u32, start: u64, end: Option<u64>) -> Result<(u32, Vec<f64>), WavError> {
    let mut f = File::open(path)?;
    let info = wav::read_info(&mut f)?;
    let win = 1u64.max(info.sample_rate as u64 * window_ms as u64 / 1000) as usize;
    let mut out = Vec::new();
    let (mut acc, mut cnt) = (0.0f64, 0usize);
    wav::for_blocks(&mut f, &info, start, end, (win * 64) as u64, |block| {
        let n = block[0].len();
        for i in 0..n {
            let mut v = 0.0f64;
            for c in block {
                v = v.max((c[i] as f64).abs());
            }
            acc += v * v;
            cnt += 1;
            if cnt == win {
                out.push(if acc <= 0.0 { -120.0 } else { 10.0 * (acc / cnt as f64).ln() / std::f64::consts::LN_10 });
                acc = 0.0;
                cnt = 0;
            }
        }
    })?;
    Ok((info.sample_rate, out))
}

/// Runs of samples at or above `level` lasting at least `min_run` frames.
pub fn find_clipping(path: &str, level: f64, min_run: u64) -> Result<Vec<(u64, u64)>, WavError> {
    let mut f = File::open(path)?;
    let info = wav::read_info(&mut f)?;
    let mut out = Vec::new();
    let mut pos = 0u64;
    let mut s: Option<u64> = None;
    wav::for_blocks(&mut f, &info, 0, None, 65536, |block| {
        let n = block[0].len();
        for i in 0..n {
            let hit = block.iter().any(|c| (c[i] as f64).abs() >= level);
            let at = pos + i as u64;
            if hit {
                s.get_or_insert(at);
            } else if let Some(st) = s.take() {
                if at - st >= min_run {
                    out.push((st, at));
                }
            }
        }
        pos += n as u64;
    })?;
    if let Some(st) = s {
        if pos - st >= min_run {
            out.push((st, pos));
        }
    }
    Ok(out)
}

// ------------------------------------------------------------------ effects

/// Small deterministic generator for Paulstretch phases (xorshift64*).
struct Rng(u64);
impl Rng {
    fn next_f64(&mut self) -> f64 {
        self.0 ^= self.0 >> 12;
        self.0 ^= self.0 << 25;
        self.0 ^= self.0 >> 27;
        (self.0.wrapping_mul(0x2545_F491_4F6C_DD1D) >> 11) as f64 / (1u64 << 53) as f64
    }
}

/// Output length of [`paulstretch`].
pub fn paulstretch_len(in_len: usize, stretch: f64) -> usize {
    (in_len as f64 * stretch).round() as usize
}

pub fn paulstretch(input: &[&[f32]], sample_rate: u32, stretch: f64, window_sec: f64) -> Vec<Vec<f32>> {
    let in_len = input.first().map_or(0, |c| c.len());
    let win = 256usize.max(next_pow2((window_sec * sample_rate as f64).round() as usize));
    let half = win / 2;
    let w = hann(win);
    let out_len = paulstretch_len(in_len, stretch) + win;
    let mut rng = Rng(42);
    let mut out = vec![vec![0f32; out_len]; input.len()];
    let hop_in = half as f64 / stretch;
    let (mut re, mut im) = (vec![0f64; win], vec![0f64; win]);
    let mut pos_in = 0.0f64;
    let mut pos_out = 0usize;
    while pos_out + win <= out_len {
        let start = pos_in.floor() as usize;
        for (c, src) in input.iter().enumerate() {
            for i in 0..win {
                let idx = start + i;
                re[i] = if idx < in_len { src[idx] as f64 } else { 0.0 } * w[i];
                im[i] = 0.0;
            }
            fft(&mut re, &mut im, false);
            for i in 0..win {
                let mag = (re[i] * re[i] + im[i] * im[i]).sqrt();
                let ph = rng.next_f64() * 2.0 * PI;
                re[i] = mag * ph.cos();
                im[i] = mag * ph.sin();
            }
            fft(&mut re, &mut im, true);
            let dst = &mut out[c];
            for i in 0..win {
                dst[pos_out + i] = (dst[pos_out + i] as f64 + re[i] * w[i]) as f32;
            }
        }
        pos_in += hop_in;
        if pos_in >= in_len as f64 {
            break;
        }
        pos_out += half;
    }
    // Random phases change the overlap-add gain: match the input loudness.
    let keep = out_len.min(paulstretch_len(in_len, stretch));
    let rms = |x: &[f32], n: usize| -> f64 {
        if n == 0 {
            return 0.0;
        }
        let s: f64 = x[..n].iter().map(|&v| v as f64 * v as f64).sum();
        (s / n as f64).sqrt()
    };
    let r_in = input.iter().map(|c| rms(c, in_len)).fold(0.0, f64::max);
    let r_out = out.iter().map(|c| rms(c, keep)).fold(0.0, f64::max);
    let g = if r_out <= 0.0 { 1.0 } else { r_in / r_out };
    out.into_iter().map(|ch| ch[..keep].iter().map(|&v| (v as f64 * g) as f32).collect()).collect()
}

/// Wah-wah: a resonant band-pass (state-variable filter) swept by an LFO.
pub fn wahwah(
    input: &[&[f32]],
    sample_rate: u32,
    lfo_hz: f64,
    depth: f64,
    resonance: f64,
    offset: f64,
) -> Vec<Vec<f32>> {
    const F_MIN: f64 = 300.0;
    const F_MAX: f64 = 3000.0;
    let q = 1.0 / resonance.clamp(0.1, 10.0);
    let sr = sample_rate as f64;
    input
        .iter()
        .map(|src| {
            let (mut low, mut band) = (0.0f64, 0.0f64);
            src.iter()
                .enumerate()
                .map(|(i, &x)| {
                    let x = x as f64;
                    let lfo = 0.5 + 0.5 * (2.0 * PI * lfo_hz * i as f64 / sr).sin();
                    let pos = (offset + depth * (lfo - 0.5)).clamp(0.0, 1.0);
                    let fc = F_MIN * (F_MAX / F_MIN).powf(pos);
                    let f = 2.0 * (PI * fc / sr).sin();
                    let high = x - low - q * band;
                    band += f * high;
                    low += f * band;
                    (0.3 * x + 0.9 * band).clamp(-4.0, 4.0) as f32
                })
                .collect()
        })
        .collect()
}

fn sliding_positions(n: usize, from_pct: f64, to_pct: f64) -> Vec<f64> {
    let (r0, r1) = (1.0 + from_pct / 100.0, 1.0 + to_pct / 100.0);
    let mut out = Vec::new();
    let mut pos = 0.0f64;
    let nf = n as f64;
    while pos < nf - 1.0 {
        out.push(pos);
        let t = pos / nf;
        pos += (r0 + (r1 - r0) * t).clamp(0.05, 10.0);
    }
    out
}

pub fn sliding_speed_len(n: usize, from_pct: f64, to_pct: f64) -> usize {
    sliding_positions(n, from_pct, to_pct).len()
}

/// Varispeed with a linear ramp (speed and pitch change together).
pub fn sliding_speed(input: &[&[f32]], from_pct: f64, to_pct: f64) -> Vec<Vec<f32>> {
    let n = input.first().map_or(0, |c| c.len());
    let positions = sliding_positions(n, from_pct, to_pct);
    input
        .iter()
        .map(|src| {
            positions
                .iter()
                .map(|&x| {
                    let i = x.floor() as usize;
                    let f = x - i as f64;
                    (src[i] as f64 * (1.0 - f) + src[(i + 1).min(n - 1)] as f64 * f) as f32
                })
                .collect()
        })
        .collect()
}
