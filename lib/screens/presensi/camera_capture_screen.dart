import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/theme.dart';
import '../../core/utils/camera_utils.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/scanner_overlay.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({Key? key}) : super(key: key);

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  CameraDescription? _frontCamera;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;

  // Quality gate
  bool _isFaceDetected = false;
  bool _isDistanceOk = false;
  bool _isBrightnessOk = false;
  double _faceRatio = 0.0;
  double _brightness = 0.0;

  late FaceDetector _faceDetector;

  bool get _allChecksValid =>
      _isFaceDetected && _isDistanceOk && _isBrightnessOk;

  String get _qualityMessage {
    if (!_isFaceDetected) return 'Arahkan wajah ke dalam bingkai';
    if (_faceRatio < 0.20) return 'Terlalu jauh, dekatkan wajah';
    if (_faceRatio > 0.70) return 'Terlalu dekat, mundur sedikit';
    if (!_isBrightnessOk) return 'Pencahayaan kurang terang';
    return 'Siap — ambil foto';
  }

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _frontCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    if (!mounted) return;

    _controller!.startImageStream((CameraImage image) {
      if (!mounted || _capturedImage != null) return;
      _processFrame(image);
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      _brightness = BrightnessUtils.calculateBrightness(image);
      _isBrightnessOk = _brightness > 60;

      final inputImage = CameraUtils.inputImageFromCameraImage(
        image: image,
        camera: _frontCamera!,
        rotation: CameraUtils.rotationIntToImageRotation(
            _frontCamera!.sensorOrientation),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final imageWidth = image.width.toDouble();
        _faceRatio = face.boundingBox.width / imageWidth;
        _isFaceDetected = true;
        _isDistanceOk = _faceRatio >= 0.20 && _faceRatio <= 0.70;
      } else {
        _isFaceDetected = false;
        _isDistanceOk = false;
        _faceRatio = 0.0;
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error processing frame: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_allChecksValid) return;
    try {
      try {
        await _controller!.stopImageStream();
      } catch (_) {}

      final image = await _controller!.takePicture();
      HapticFeedback.lightImpact();
      if (!mounted) return;

      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
      _isFaceDetected = false;
      _isDistanceOk = false;
      _isBrightnessOk = false;
    });

    _controller!.startImageStream((CameraImage image) {
      if (!mounted || _capturedImage != null) return;
      _processFrame(image);
    });
  }

  void _usePicture() {
    if (_capturedImage != null) {
      Navigator.pop(context, File(_capturedImage!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize?.height ??
                      MediaQuery.of(context).size.width,
                  height: _controller!.value.previewSize?.width ??
                      MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            const Center(
                child: CircularProgressIndicator(color: Colors.white)),

          if (_capturedImage != null)
            SizedBox.expand(
              child: Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
            ),

          ScannerOverlay(
            borderColor: _capturedImage != null
                ? AppTheme.statusGreen
                : _allChecksValid
                    ? AppTheme.statusGreen
                    : _isFaceDetected
                        ? AppTheme.statusYellow
                        : AppTheme.primaryBlue,
            isScanning: _capturedImage == null,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Ambil Foto Selfie",
                  style: AppTheme.heading3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        _capturedImage != null
                            ? "Foto berhasil diambil ✓"
                            : _qualityMessage,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                          color: _capturedImage != null
                              ? AppTheme.statusGreen
                              : _allChecksValid
                                  ? AppTheme.statusGreen
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quality chips (saat belum capture)
                if (_capturedImage == null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip(Icons.face, 'Wajah', _isFaceDetected),
                      const SizedBox(width: 6),
                      _buildChip(Icons.straighten, 'Jarak', _isDistanceOk),
                      const SizedBox(width: 6),
                      _buildChip(
                          Icons.wb_sunny_outlined, 'Cahaya', _isBrightnessOk),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _capturedImage != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Foto Ulang",
                          type: ButtonType.secondary,
                          onPressed: _retakePicture,
                          icon: Icons.refresh,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: "Gunakan",
                          type: ButtonType.primary,
                          onPressed: _usePicture,
                          icon: Icons.check,
                          backgroundColor: AppTheme.statusGreen,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: GestureDetector(
                      onTap: _allChecksValid ? _takePicture : null,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _allChecksValid
                                ? Colors.white.withOpacity(0.8)
                                : Colors.white.withOpacity(0.3),
                            width: 6,
                          ),
                          color: _allChecksValid
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          boxShadow: _allChecksValid
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ]
                              : null,
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _allChecksValid
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, bool isOk) {
    final color = isOk ? AppTheme.statusGreen : Colors.white.withOpacity(0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOk ? Icons.check_circle : icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
