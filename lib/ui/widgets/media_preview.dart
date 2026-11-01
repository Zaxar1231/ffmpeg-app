import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// libmpv-backed preview for a local file (video or audio).
class MediaPreview extends StatefulWidget {
  const MediaPreview({super.key, required this.path, this.aspectRatio = 16 / 9, this.onPlayer});
  final String path;
  final double aspectRatio;

  /// Gives the owner access to the player (seek, position) — used by Trim.
  final ValueChanged<Player>? onPlayer;

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);

  @override
  void initState() {
    super.initState();
    _player.open(Media(widget.path), play: false);
    widget.onPlayer?.call(_player);
  }

  @override
  void didUpdateWidget(covariant MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _player.open(Media(widget.path), play: false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Video(controller: _controller, controls: MaterialDesktopVideoControls),
      ),
    );
  }
}
