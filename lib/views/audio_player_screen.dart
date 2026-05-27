import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget{
  String audioUrl;


  AudioPlayerScreen(this.audioUrl, {super.key});

  @override
  _audioPlayerState createState()=>_audioPlayerState();
}
class _audioPlayerState extends State<AudioPlayerScreen>{
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  PlayerState _playerState = PlayerState.stopped;
  bool _isLoading = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  String fileName="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Now Playing",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 10),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),

            /// Progress bar or loader
            _isLoading
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white54,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                    thumbShape:
                    RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(), // Cast to double
                    value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()), // Cast to double
                    onChanged: _seek,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(_position),
                        style: TextStyle(color: Colors.white70)),
                    Text(_formatTime(_duration),
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),

            /// Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(Icons.stop, _stop, Colors.redAccent),
                SizedBox(width: 30),
                _buildControlButton(Icons.play_arrow, _play, Colors.greenAccent),
                SizedBox(width: 30),
                _buildControlButton(Icons.pause, _pause, Colors.orangeAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: color,
        foregroundColor: Colors.black,
        elevation: 8,
      ),
      child: Icon(icon, size: 28),
    );
  }

  @override
  void initState() {
    super.initState();

    fileName=getFileNameFromUrl(widget.audioUrl);
    _durationSub = _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;

        // If audio is stopped or paused, we check if it's buffering or not
        if (_playerState == PlayerState.stopped || _playerState == PlayerState.paused) {
          _isLoading = _playerState == PlayerState.stopped;  // Show loading if stopped
        } else {
          _isLoading = false;  // Hide loading once playing
        }
      });
    });
  }

  String getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'Unknown';
    return fileName;
  }

  @override
  void dispose() {
    _player.dispose();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    super.dispose();
  }


  Future<void> _play() async {
    setState(() => _isLoading = true);
    await _player.play(UrlSource(
        widget.audioUrl));
  }

  Future<void> _pause() async {
    await _player.pause();
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  void _seek(double value) {
    final seekPosition = Duration(seconds: value.toInt());
    _player.seek(seekPosition);
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }


}