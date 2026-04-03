import 'package:flutter/material.dart';
import 'package:daily_flutter/daily_flutter.dart';

class VideoTile extends StatefulWidget {
  final Participant participant;
  final bool isActiveSpeaker;

  const VideoTile({
    required this.participant,
    required this.isActiveSpeaker,
    super.key,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  final _controller = VideoViewController();

  @override
  void initState() {
    super.initState();
    _controller.setTrack(widget.participant.media?.camera.track);
  }

  @override
  void didUpdateWidget(VideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTrack = widget.participant.media?.camera.track;
    final oldTrack = oldWidget.participant.media?.camera.track;

    if (newTrack != oldTrack) {
      _controller.setTrack(newTrack);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _micOn =>
      widget.participant.media?.microphone.state == MediaState.playable;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(
          color: widget.isActiveSpeaker
              ? Colors.greenAccent
              : Colors.transparent,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            VideoView(controller: _controller),

            // Username label
            Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                '${widget.participant.info.username ?? 'Unknown'}'
                    '${widget.participant.info.isLocal ? ' (You)' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),

            // Microphone / Active Speaker indicator
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Colors.black54,
                child: Icon(
                  widget.isActiveSpeaker ? Icons.mic : Icons.mic_off,
                  size: 14,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}