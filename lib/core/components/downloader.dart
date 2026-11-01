import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class DownloadProgress {
  const DownloadProgress(this.received, this.total, this.bytesPerSecond);
  final int received;

  /// Null when the server sent no Content-Length.
  final int? total;
  final double bytesPerSecond;
  double? get fraction => total == null || total == 0 ? null : received / total!;
}

class DownloadCanceled implements Exception {
  @override
  String toString() => 'Download canceled';
}

class ChecksumMismatch implements Exception {
  ChecksumMismatch(this.expected, this.actual);
  final String expected;
  final String actual;
  @override
  String toString() => 'SHA-256 mismatch: expected $expected, got $actual';
}

class CancelToken {
  bool _canceled = false;
  final _listeners = <void Function()>[];
  bool get isCanceled => _canceled;
  void cancel() {
    if (_canceled) return;
    _canceled = true;
    for (final l in _listeners) {
      l();
    }
  }

  void onCancel(void Function() l) => _listeners.add(l);
}

/// Streams [url] into [dest] while hashing; never buffers the whole file.
/// Returns the SHA-256 hex digest. Deletes [dest] on failure.
Future<String> downloadFile(
  String url,
  String dest, {
  String? expectedSha256,
  http.Client? client,
  void Function(DownloadProgress)? onProgress,
  CancelToken? cancel,
  String userAgent = 'Kadra',
}) async {
  final c = client ?? http.Client();
  final file = File(dest);
  await file.parent.create(recursive: true);
  IOSink? sink;
  StreamSubscription<List<int>>? sub;
  try {
    final req = http.Request('GET', Uri.parse(url))..headers['User-Agent'] = userAgent;
    final resp = await c.send(req).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) {
      throw HttpException('HTTP ${resp.statusCode}', uri: Uri.parse(url));
    }
    sink = file.openWrite();
    final digestSink = _DigestSink();
    final hasher = sha256.startChunkedConversion(digestSink);
    final total = resp.contentLength;
    var received = 0;
    final sw = Stopwatch()..start();
    var lastReport = 0;
    final done = Completer<void>();
    sub = resp.stream.listen(
      (chunk) {
        sink!.add(chunk);
        hasher.add(chunk);
        received += chunk.length;
        final now = sw.elapsedMilliseconds;
        if (onProgress != null && now - lastReport >= 150) {
          lastReport = now;
          onProgress(DownloadProgress(received, total, now == 0 ? 0 : received * 1000 / now));
        }
      },
      onError: (Object e, StackTrace st) {
        if (!done.isCompleted) done.completeError(e, st);
      },
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
      cancelOnError: true,
    );
    cancel?.onCancel(() {
      sub?.cancel();
      if (!done.isCompleted) done.completeError(DownloadCanceled());
    });
    if (cancel?.isCanceled ?? false) throw DownloadCanceled();
    await done.future;
    hasher.close();
    await sink.flush();
    await sink.close();
    sink = null;
    onProgress?.call(DownloadProgress(received, total ?? received, 0));
    final actual = digestSink.value.toString();
    if (expectedSha256 != null && actual != expectedSha256.toLowerCase()) {
      throw ChecksumMismatch(expectedSha256, actual);
    }
    return actual;
  } catch (_) {
    await sub?.cancel();
    await sink?.close();
    if (await file.exists()) await file.delete();
    rethrow;
  } finally {
    if (client == null) c.close();
  }
}

/// SHA-256 of a file on disk (used to verify the result of a download).
Future<String> sha256OfFile(String path) async {
  final s = _DigestSink();
  final h = sha256.startChunkedConversion(s);
  await for (final chunk in File(path).openRead()) {
    h.add(chunk);
  }
  h.close();
  return s.value.toString();
}

class _DigestSink implements Sink<Digest> {
  late Digest value;
  @override
  void add(Digest data) => value = data;
  @override
  void close() {}
}
