import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/theme.dart';
import '../../core/utils/camera_utils.dart';
import '../../repositories/face_repository.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/scanner_overlay.dart';

class FaceTestScreen extends StatefulWidget {
  const FaceTestScreen({super.key});

  @override
  State<FaceTestScreen> createState() => _FaceTestScreenState();
}

class _FaceTestScreenState extends State<FaceTestScreen> {
  CameraController? _cameraController;
  CameraDescription? _frontCamera;
  bool _isCameraInitialized = false;
  bool _isVerifying = false;
  bool _showResult = false;
  bool _isProcessingFrame = false;

  // Quality gate
  bool _isFaceDetected = false;
  bool _isDistanceOk = false;
  bool _isBrightnessOk = false;
  double _faceRatio = 0.0;
  double _brightness = 0.0;

  bool? _verified;
  double? _confidence;
  double? _svmConfidence;
  String? _statusText;
  String? _errorMessage;

  late FaceDetector _faceDetector;

  bool get _allChecksValid =>
      _isFaceDetected && _isDistanceOk && _isBrightnessOk;

  String get _qualityMessage {
    if (!_isFaceDetected) return 'Arahkan wajah ke dalam bingkai';
    if (_faceRatio < 0.20) return 'Terlalu jauh, dekatkan wajah';
    if (_faceRatio > 0.70) return 'Terlalu dekat, mundur sedikit';
    if (!_isBrightnessOk) return 'Pencahayaan kurang terang';
    return 'Siap — mulai verifikasi';
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
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      _startQualityStream();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _startQualityStream() {
    _cameraController!.startImageStream((CameraImage image) {
      if (!mounted || _showResult || _isVerifying) return;
      _processFrame(image);
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

  Future<void> _captureAndVerify() async {
    if (_cameraController == null || _isVerifying || !_allChecksValid) return;

    setState(() {
      _isVerifying = true;
      _showResult = false;
      _errorMessage = null;
    });

    try {
      try {
        await _cameraController!.stopImageStream();
      } catch (_) {}

      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      final result =
          await FaceRepository().verifyFace(imageFile, tipe: 'test');

      if (mounted) {
        setState(() {
          _verified = result['verified'] == true;
          _confidence = (result['confidence'] is num)
              ? (result['confidence'] as num).toDouble()
              : null;
          _svmConfidence = (result['svm_confidence'] is num)
              ? (result['svm_confidence'] as num).toDouble()
              : null;
          _statusText = result['verification_status']?.toString() ??
              result['status']?.toString();
          _showResult = true;
          _isVerifying = false;
        });

        if (_verified == true) {
          HapticFeedback.lightImpact();
        } else {
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verified = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _showResult = true;
          _isVerifying = false;
        });
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _resetTest() {
    setState(() {
      _showResult = false;
      _verified = null;
      _confidence = null;
      _svmConfidence = null;
      _statusText = null;
      _errorMessage = null;
      _isFaceDetected = false;
      _isDistanceOk = false;
      _isBrightnessOk = false;
    });

    _startQualityStream();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
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
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
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
                  width: _cameraController!.value.previewSize?.height ??
                      MediaQuery.of(context).size.width,
                  height: _cameraController!.value.previewSize?.width ??
                      MediaQuery.of(context).size.height,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          ScannerOverlay(
            borderColor: _showResult
                ? (_verified == true
                    ? AppTheme.statusGreen
                    : AppTheme.statusRed)
                : _allChecksValid
                    ? AppTheme.statusGreen
                    : _isFaceDetected
                        ? AppTheme.statusYellow
                        : AppTheme.primaryBlue,
            isScanning: _isVerifying || (!_showResult && !_isVerifying),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Test Pengenalan Wajah",
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
                        _isVerifying
                            ? "Memverifikasi wajah..."
                            : _showResult
                                ? (_verified == true
                                    ? "Wajah Terverifikasi ✓"
                                    : "Wajah Tidak Cocok ✗")
                                : _qualityMessage,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                          color: _showResult
                              ? (_verified == true
                                  ? AppTheme.statusGreen
                                  : AppTheme.statusRed)
                              : _allChecksValid
                                  ? AppTheme.statusGreen
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quality chips
                if (!_showResult && !_isVerifying) ...[
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

          if (_showResult)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _showResult ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_verified == true
                                      ? AppTheme.statusGreen
                                      : AppTheme.statusRed)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _verified == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _verified == true
                                  ? AppTheme.statusGreen
                                  : AppTheme.statusRed,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _verified == true
                                ? "Verifikasi Berhasil"
                                : "Verifikasi Gagal",
                            style: AppTheme.heading3.copyWith(
                              color: _verified == true
                                  ? AppTheme.statusGreen
                                  : AppTheme.statusRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_confidence != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%",
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _confidence! >= 0.85
                                        ? "Sangat cocok (≥ 85%)"
                                        : _confidence! >= 0.65
                                            ? "Cukup cocok (65-85%)"
                                            : "Tidak cocok (< 65%)",
                                    style: AppTheme.bodySmall.copyWith(
                                      color: _confidence! >= 0.85
                                          ? AppTheme.statusGreen
                                          : _confidence! >= 0.65
                                              ? AppTheme.statusYellow
                                              : AppTheme.statusRed,
                                    ),
                                  ),
                                  if (_svmConfidence != null) ...[
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Text(
                                      "SVM Conf: ${(_svmConfidence! * 100).toStringAsFixed(1)}%",
                                      style:
                                          AppTheme.labelMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (_statusText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                ),
                                child: Text(
                                  "Status: $_statusText",
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.statusRed,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                if (!_showResult && !_isVerifying)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Mulai Verifikasi",
                      icon: Icons.face_rounded,
                      onPressed: _allChecksValid && _isCameraInitialized
                          ? _captureAndVerify
                          : null,
                      backgroundColor: _allChecksValid
                          ? AppTheme.primaryBlue
                          : AppTheme.primaryDark.withOpacity(0.5),
                    ),
                  ),
                if (_isVerifying)
                  const CircularProgressIndicator(color: Colors.white),
                if (_showResult)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Coba Lagi",
                          type: ButtonType.primary,
                          onPressed: _resetTest,
                        ),
                      ),
                    ],
                  ),
              ],
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
