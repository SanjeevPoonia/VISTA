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
  String? _cameraError;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  initializeCamera() async {
    print("Camera Triggered");
    _controller = CameraController(
      cameras[cameraSelection],
      ResolutionPreset.medium,
    );

    _controller!.initialize().then((_)async {
      if (!mounted) return;
      _minZoomLevel = await _controller!.getMinZoomLevel();
      _maxZoomLevel = await _controller!.getMaxZoomLevel();
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
      if (cameraSelection >= cameras.length) {
        cameraSelection = 0;
      }
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
    /*if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }*/
    _controller?.dispose();
    super.dispose();
  }
  Future<void> _zoomIn() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    double zoom = (_currentZoomLevel + 0.5)
        .clamp(_minZoomLevel, _maxZoomLevel);

    await _controller!.setZoomLevel(zoom);

    setState(() {
      _currentZoomLevel = zoom;
    });
  }
  Future<void> _zoomOut() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    double zoom = (_currentZoomLevel - 0.5)
        .clamp(_minZoomLevel, _maxZoomLevel);

    await _controller!.setZoomLevel(zoom);

    setState(() {
      _currentZoomLevel = zoom;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Container(
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

          /* Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentZoomLevel.toStringAsFixed(1)}x",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // ✅ Bottom Controls (hide if error)*/
          if (_cameraError == null)
            Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 25,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Zoom Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Text(
                          "${_currentZoomLevel.toStringAsFixed(1)}x",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [

                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.10),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _controlButton(
                                    icon: Icons.remove,
                                    onTap: _zoomOut,
                                  ),

                                  const SizedBox(width: 6),

                                  Flexible(
                                    child: Icon(Icons.zoom_in,size: 32,color: AppTheme.orangeColor,),
                                  ),

                                  const SizedBox(width: 6),

                                  _controlButton(
                                    icon: Icons.add,
                                    onTap: _zoomIn,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              if (_controller == null ||
                                  !_controller!.value.isInitialized) {
                                return;
                              }

                              XFile file = await _controller!.takePicture();

                              if (mounted) {
                                Navigator.pop(context, file);
                              }
                            },
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.orangeColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _controlButton(
                            icon: Icons.cameraswitch_rounded,
                            onTap: _cameraChange,
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
        ],
      ),
    ));
  }
  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
  Future<void> _cameraChange() async {

    await _controller?.dispose();

    /*if (cameraSelection == 1) {
      cameraSelection = 0;
    } else {
      cameraSelection = 1;
    }*/
    cameraSelection = (cameraSelection + 1) % cameras.length;

    await getCameras();
  }
}