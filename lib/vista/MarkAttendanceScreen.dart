import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vista/utils/app_theme.dart';
class MarkAttendanceScreen extends StatefulWidget{
   int cameraSelected=1;
  MarkAttendanceScreen(this.cameraSelected, {super.key});

  _markAttendance createState()=>_markAttendance();
}
class _markAttendance extends State<MarkAttendanceScreen> {

  CameraController? _controller;
  CameraDescription? camera;
  List<CameraDescription> cameras = [];
  int cameraSelection = 0;

  String? _cameraError; // ✅ Error message track करने के लिए

  initializeCamera() async {
    print("Camera Triggered");
    _controller = CameraController(
      cameras[cameraSelection],
      ResolutionPreset.medium,
    );

    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _cameraError = null; // success case
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        setState(() {
          if (e.code == 'CameraAccessDenied') {
            _cameraError = "Camera permission denied.";
          } else {
            _cameraError = "Camera error: ${e.description}";
          }
        });
      } else {
        setState(() {
          _cameraError = "Unknown error: $e";
        });
      }
    });
  }

  Future<void> getCameras() async {
    try {
      cameras = await availableCameras();
      initializeCamera();
    } catch (e) {
      setState(() {
        _cameraError = "Unable to fetch cameras: $e";
      });
    }
    if (cameras.isNotEmpty) {
      camera = cameras.last;
      print(camera);
    }
  }

  @override
  void initState() {
    super.initState();
    cameraSelection = widget.cameraSelected;
    getCameras();
  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // ✅ Full Screen Camera Preview / Error / Loader
          if (_cameraError != null)
            Center(
              child: Text(
                _cameraError!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          else
            if (_controller == null || !_controller!.value.isInitialized)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),

          // ✅ Bottom Controls (hide if error)
          if (_cameraError == null)
            Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: AppTheme.camBackColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Container()),

                          // Take Picture Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (_controller != null &&
                                    _controller!.value.isInitialized) {
                                  XFile file = await _controller!.takePicture();
                                  Navigator.pop(context, file);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                Icons.camera,
                                color: AppTheme.orangeColor,
                                size: 60,
                              ),
                            ),
                          ),

                          // Switch Camera Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _cameraChange();
                              },
                              child: Icon(
                                Icons.flip_camera_android,
                                color: AppTheme.themeColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  _cameraChange() {
    if (cameraSelection == 1) {
      cameraSelection = 0;
    } else if (cameraSelection == 0) {
      cameraSelection = 1;
    }
    getCameras();
  }
}