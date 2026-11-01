/// Audio editor project model (multitrack, Audacity-style).
///
/// A track's audio lives in a 32-bit float WAV in the project's working
/// folder. Every destructive edit renders a *new* file, so a project state is
/// just a set of file references and undo/redo is switching states.
/// Gain, pan, mute/solo, time offset and the volume envelope are
/// non-destructive and applied when mixing/exporting.
library;

import 'dart:convert';

/// A time range in sample frames, `[start, end)`.
class SampleRange {
  const SampleRange(this.start, this.end);
  final int start;
  final int end;
  int get length => end - start;
  bool get isEmpty => end <= start;

  SampleRange clamp(int max) => SampleRange(start.clamp(0, max), end.clamp(0, max));

  Map<String, Object?> toJson() => {'s': start, 'e': end};
  factory SampleRange.fromJson(Map<String, dynamic> j) => SampleRange(j['s'] as int, j['e'] as int);

  @override
  bool operator ==(Object other) => other is SampleRange && other.start == start && other.end == end;
  @override
  int get hashCode => Object.hash(start, end);
  @override
  String toString() => '[$start, $end)';
}

/// Envelope point: time in seconds on the track's own timeline, gain factor.
class EnvelopePoint {
  const EnvelopePoint(this.time, this.gain);
  final double time;
  final double gain;
  Map<String, Object?> toJson() => {'t': time, 'g': gain};
  factory EnvelopePoint.fromJson(Map<String, dynamic> j) =>
      EnvelopePoint((j['t'] as num).toDouble(), (j['g'] as num).toDouble());
}

class AudioTrack {
  const AudioTrack({
    required this.id,
    required this.name,
    required this.file,
    required this.frames,
    required this.channels,
    this.offset = 0,
    this.gainDb = 0,
    this.pan = 0,
    this.mute = false,
    this.solo = false,
    this.envelope = const [],
  });

  final String id;
  final String name;

  /// Working WAV (f32, project sample rate).
  final String file;
  final int frames;
  final int channels;

  /// Start position on the project timeline (frames). Time-shift tool.
  final int offset;
  final double gainDb;

  /// −1 (left) … 1 (right).
  final double pan;
  final bool mute;
  final bool solo;
  final List<EnvelopePoint> envelope;

  int get end => offset + frames;

  AudioTrack copyWith({
    String? name,
    String? file,
    int? frames,
    int? channels,
    int? offset,
    double? gainDb,
    double? pan,
    bool? mute,
    bool? solo,
    List<EnvelopePoint>? envelope,
  }) => AudioTrack(
    id: id,
    name: name ?? this.name,
    file: file ?? this.file,
    frames: frames ?? this.frames,
    channels: channels ?? this.channels,
    offset: offset ?? this.offset,
    gainDb: gainDb ?? this.gainDb,
    pan: pan ?? this.pan,
    mute: mute ?? this.mute,
    solo: solo ?? this.solo,
    envelope: envelope ?? this.envelope,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'file': file,
    'frames': frames,
    'channels': channels,
    'offset': offset,
    'gainDb': gainDb,
    'pan': pan,
    'mute': mute,
    'solo': solo,
    'envelope': envelope.map((e) => e.toJson()).toList(),
  };

  factory AudioTrack.fromJson(Map<String, dynamic> j) => AudioTrack(
    id: j['id'] as String,
    name: j['name'] as String,
    file: j['file'] as String,
    frames: j['frames'] as int,
    channels: j['channels'] as int,
    offset: j['offset'] as int? ?? 0,
    gainDb: (j['gainDb'] as num?)?.toDouble() ?? 0,
    pan: (j['pan'] as num?)?.toDouble() ?? 0,
    mute: j['mute'] as bool? ?? false,
    solo: j['solo'] as bool? ?? false,
    envelope: [
      for (final e in (j['envelope'] as List? ?? const [])) EnvelopePoint.fromJson((e as Map).cast<String, dynamic>()),
    ],
  );
}

/// Label: a point (start == end) or a region, in project frames.
class AudioLabel {
  const AudioLabel(this.id, this.start, this.end, this.text);
  final String id;
  final int start;
  final int end;
  final String text;
  AudioLabel copyWith({int? start, int? end, String? text}) =>
      AudioLabel(id, start ?? this.start, end ?? this.end, text ?? this.text);
  Map<String, Object?> toJson() => {'id': id, 's': start, 'e': end, 't': text};
  factory AudioLabel.fromJson(Map<String, dynamic> j) =>
      AudioLabel(j['id'] as String, j['s'] as int, j['e'] as int, j['t'] as String? ?? '');
}

class AudioProjectState {
  const AudioProjectState({required this.sampleRate, this.tracks = const [], this.labels = const []});

  final int sampleRate;
  final List<AudioTrack> tracks;
  final List<AudioLabel> labels;

  int get length => tracks.fold(0, (m, t) => t.end > m ? t.end : m);
  Duration get duration => Duration(microseconds: length * 1000000 ~/ sampleRate);
  AudioTrack? track(String id) => tracks.where((t) => t.id == id).firstOrNull;

  /// Tracks that are heard: solo wins, mute hides.
  List<AudioTrack> get audible {
    final solo = tracks.where((t) => t.solo).toList();
    return (solo.isNotEmpty ? solo : tracks).where((t) => !t.mute).toList();
  }

  AudioProjectState copyWith({List<AudioTrack>? tracks, List<AudioLabel>? labels, int? sampleRate}) =>
      AudioProjectState(
        sampleRate: sampleRate ?? this.sampleRate,
        tracks: tracks ?? this.tracks,
        labels: labels ?? this.labels,
      );

  AudioProjectState replaceTrack(AudioTrack t) => copyWith(tracks: [for (final x in tracks) x.id == t.id ? t : x]);

  Map<String, Object?> toJson() => {
    'kadra': 'audio-project',
    'version': 1,
    'sampleRate': sampleRate,
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'labels': labels.map((l) => l.toJson()).toList(),
  };

  factory AudioProjectState.fromJson(Map<String, dynamic> j) {
    if (j['kadra'] != 'audio-project') throw const FormatException('Not a Kadra audio project');
    return AudioProjectState(
      sampleRate: j['sampleRate'] as int,
      tracks: [for (final t in j['tracks'] as List) AudioTrack.fromJson((t as Map).cast<String, dynamic>())],
      labels: [
        for (final l in (j['labels'] as List? ?? const [])) AudioLabel.fromJson((l as Map).cast<String, dynamic>()),
      ],
    );
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());
}

// ------------------------------------------------------------ labels I/O

/// Audacity-compatible label file: `start\tend\ttext` (seconds).
String exportLabelsText(List<AudioLabel> labels, int sampleRate) => [
  for (final l in labels)
    '${(l.start / sampleRate).toStringAsFixed(6)}\t${(l.end / sampleRate).toStringAsFixed(6)}\t${l.text}',
].join('\n');

List<AudioLabel> importLabelsText(String text, int sampleRate, {required String Function() newId}) {
  final out = <AudioLabel>[];
  for (final raw in text.split('\n')) {
    final line = raw.trimRight();
    if (line.isEmpty || line.startsWith('\\')) continue; // spectral-selection lines
    final parts = line.split('\t');
    if (parts.length < 2) continue;
    final s = double.tryParse(parts[0].replaceAll(',', '.'));
    final e = double.tryParse(parts[1].replaceAll(',', '.'));
    if (s == null || e == null) continue;
    out.add(
      AudioLabel(
        newId(),
        (s * sampleRate).round(),
        (e * sampleRate).round(),
        parts.length > 2 ? parts.sublist(2).join('\t') : '',
      ),
    );
  }
  return out;
}
