/// Minimal RIFF/WAVE reader/writer for the editor's working format:
/// 32-bit float PCM (what ffmpeg writes with `-c:a pcm_f32le`), like
/// Audacity's internal 32-bit float. Also reads 16/24/32-bit integer PCM.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

class WavInfo {
  const WavInfo({
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
    required this.isFloat,
    required this.dataOffset,
    required this.dataLength,
  });

  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final bool isFloat;
  final int dataOffset;
  final int dataLength;

  int get bytesPerFrame => channels * bitsPerSample ~/ 8;
  int get frames => dataLength ~/ bytesPerFrame;
  Duration get duration => Duration(microseconds: frames * 1000000 ~/ sampleRate);
}

/// Parses the header. Handles WAVE_FORMAT_EXTENSIBLE, RF64 and `data`
/// chunks of unknown size (0xFFFFFFFF / 0, as written to pipes).
WavInfo readWavInfo(RandomAccessFile f) {
  f.setPositionSync(0);
  final head = f.readSync(12);
  final riff = String.fromCharCodes(head.sublist(0, 4));
  if ((riff != 'RIFF' && riff != 'RF64') || String.fromCharCodes(head.sublist(8, 12)) != 'WAVE') {
    throw const FormatException('Not a WAV file');
  }
  int? rate, ch, bits;
  var isFloat = false;
  int? ds64Data;
  var pos = 12;
  final fileLen = f.lengthSync();
  while (pos + 8 <= fileLen) {
    f.setPositionSync(pos);
    final h = f.readSync(8);
    final id = String.fromCharCodes(h.sublist(0, 4));
    final size = ByteData.sublistView(h).getUint32(4, Endian.little);
    if (id == 'ds64') {
      final b = ByteData.sublistView(f.readSync(math.min(size, 28)));
      ds64Data = b.getUint64(8, Endian.little);
    } else if (id == 'fmt ') {
      final b = ByteData.sublistView(f.readSync(size));
      final tag = b.getUint16(0, Endian.little);
      ch = b.getUint16(2, Endian.little);
      rate = b.getUint32(4, Endian.little);
      bits = b.getUint16(14, Endian.little);
      var format = tag;
      if (tag == 0xFFFE && size >= 26) format = b.getUint16(24, Endian.little); // SubFormat GUID's first 2 bytes
      isFloat = format == 3;
    } else if (id == 'data') {
      var len = size;
      if (ds64Data != null && size == 0xFFFFFFFF) len = ds64Data;
      if (size == 0xFFFFFFFF || size == 0 || pos + 8 + len > fileLen) len = fileLen - pos - 8;
      if (rate == null || ch == null || bits == null) throw const FormatException('WAV without fmt chunk');
      return WavInfo(
        sampleRate: rate,
        channels: ch,
        bitsPerSample: bits,
        isFloat: isFloat,
        dataOffset: pos + 8,
        dataLength: len,
      );
    }
    pos += 8 + size + (size.isOdd ? 1 : 0);
  }
  throw const FormatException('WAV without data chunk');
}

/// Reads [count] frames starting at [start] as de-interleaved float channels.
List<Float32List> readFrames(RandomAccessFile f, WavInfo info, int start, int count) {
  final s = start.clamp(0, info.frames);
  final n = math.max(0, math.min(count, info.frames - s));
  final out = List.generate(info.channels, (_) => Float32List(n));
  if (n == 0) return out;
  f.setPositionSync(info.dataOffset + s * info.bytesPerFrame);
  final bytes = f.readSync(n * info.bytesPerFrame);
  decodeInto(bytes, info, out, 0);
  return out;
}

/// Decodes interleaved PCM [bytes] into [out] starting at frame [offset].
void decodeInto(Uint8List bytes, WavInfo info, List<Float32List> out, int offset) {
  final bd = ByteData.sublistView(bytes);
  final ch = info.channels;
  final frames = bytes.length ~/ info.bytesPerFrame;
  final bps = info.bitsPerSample ~/ 8;
  for (var i = 0; i < frames; i++) {
    for (var c = 0; c < ch; c++) {
      final o = (i * ch + c) * bps;
      double v;
      if (info.isFloat && bps == 4) {
        v = bd.getFloat32(o, Endian.little);
      } else if (info.isFloat && bps == 8) {
        v = bd.getFloat64(o, Endian.little);
      } else if (bps == 2) {
        v = bd.getInt16(o, Endian.little) / 32768.0;
      } else if (bps == 3) {
        var x = bytes[o] | (bytes[o + 1] << 8) | (bytes[o + 2] << 16);
        if (x & 0x800000 != 0) x -= 0x1000000;
        v = x / 8388608.0;
      } else if (bps == 4) {
        v = bd.getInt32(o, Endian.little) / 2147483648.0;
      } else {
        v = (bytes[o] - 128) / 128.0;
      }
      out[c][offset + i] = v;
    }
  }
}

/// Streams all frames in blocks (for analyzers over long files).
Iterable<List<Float32List>> readBlocks(
  RandomAccessFile f,
  WavInfo info, {
  int start = 0,
  int? end,
  int block = 65536,
}) sync* {
  final stop = math.min(end ?? info.frames, info.frames);
  for (var s = math.max(0, start); s < stop; s += block) {
    yield readFrames(f, info, s, math.min(block, stop - s));
  }
}

/// Writes 32-bit float WAV (WAVE_FORMAT_IEEE_FLOAT).
Future<void> writeWavFloat(String path, List<Float32List> channels, int sampleRate) async {
  final ch = channels.length;
  final frames = channels.isEmpty ? 0 : channels.first.length;
  final dataLen = frames * ch * 4;
  final header = ByteData(44)
    ..setUint32(0, 0x46464952, Endian.little) // RIFF
    ..setUint32(4, 36 + dataLen, Endian.little)
    ..setUint32(8, 0x45564157, Endian.little) // WAVE
    ..setUint32(12, 0x20746d66, Endian.little) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 3, Endian.little)
    ..setUint16(22, ch, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * ch * 4, Endian.little)
    ..setUint16(32, ch * 4, Endian.little)
    ..setUint16(34, 32, Endian.little)
    ..setUint32(36, 0x61746164, Endian.little) // data
    ..setUint32(40, dataLen, Endian.little);
  final sink = File(path).openWrite();
  sink.add(header.buffer.asUint8List());
  const block = 65536;
  for (var s = 0; s < frames; s += block) {
    final n = math.min(block, frames - s);
    final bd = ByteData(n * ch * 4);
    for (var i = 0; i < n; i++) {
      for (var c = 0; c < ch; c++) {
        bd.setFloat32((i * ch + c) * 4, channels[c][s + i], Endian.little);
      }
    }
    sink.add(bd.buffer.asUint8List());
  }
  await sink.close();
}
