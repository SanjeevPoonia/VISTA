import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordingDialog extends StatefulWidget{
  String fileNameCustom;

  AudioRecordingDialog(this.fileNameCustom);

  @override
  _audioRecordingState createState() => _audioRecordingState();
}
class _audioRecordingState extends State<AudioRecordingDialog>{
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
    await _player.openPlayer();

    var micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      Navigator.pop(context); // Close dialog if no permission
    }
  }
  Future<void> _startRecording() async {
    final directoryPath=await getFilePath();
    _filePath = '$directoryPath${widget.fileNameCustom}.aac';
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );
    setState(() => _isRecording = true);
  }
  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    Navigator.pop(context, _filePath);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Audio Recorder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isRecording ? Icons.mic : Icons.mic_none,
            color: _isRecording ? Colors.red : Colors.black,
            size: 48,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
          ),

        ],
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context,_filePath),
        ),
      ],
    );
  }

  Future<String> getFilePath() async {
    final dir = await getApplicationDocumentsDirectory(); // Safe app-private directory
    return '${dir.path}/';  // You can change the extension if needed
  }


}