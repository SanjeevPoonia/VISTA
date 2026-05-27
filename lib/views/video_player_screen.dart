import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}
class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    print("Video Url ${widget.videoUrl}");
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // refresh once video initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayer(_controller),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Controls
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Progress Bar
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: AppTheme.orangeColor,
                      backgroundColor: Colors.white30,
                      bufferedColor: AppTheme.themeColor.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Play / Pause button
                  FloatingActionButton(
                    backgroundColor: AppTheme.orangeColor,
                    onPressed: _togglePlayPause,
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : CircularProgressIndicator(color: AppTheme.orangeColor),
      ),
    );
  }
}