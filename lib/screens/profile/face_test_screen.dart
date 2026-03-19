import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
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
  bool _isCameraInitialized = false;
  bool _isVerifying = false;
  bool _showResult = false;

  bool? _verified;
  double? _confidence;
  String? _statusText;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _captureAndVerify() async {
    if (_cameraController == null || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _showResult = false;
      _errorMessage = null;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      final result = await FaceRepository().verifyFace(imageFile);

      if (mounted) {
        setState(() {
          _verified = result['verified'] == true;
          _confidence = (result['confidence'] is num)
              ? (result['confidence'] as num).toDouble()
              : null;
          _statusText = result['verification_status']?.toString()
              ?? result['status']?.toString();
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
      _statusText = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
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
                  width: _cameraController!.value.previewSize?.height ?? MediaQuery.of(context).size.width,
                  height: _cameraController!.value.previewSize?.width ?? MediaQuery.of(context).size.height,
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
                ? (_verified == true ? AppTheme.statusGreen : AppTheme.statusRed)
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        _isVerifying
                            ? "Memverifikasi wajah..."
                            : _showResult
                                ? (_verified == true ? "Wajah Terverifikasi ✓" : "Wajah Tidak Cocok ✗")
                                : "Posisikan wajah di dalam bingkai",
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                          color: _showResult
                              ? (_verified == true ? AppTheme.statusGreen : AppTheme.statusRed)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
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
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_verified == true ? AppTheme.statusGreen : AppTheme.statusRed).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _verified == true ? Icons.check_circle : Icons.cancel,
                              color: _verified == true ? AppTheme.statusGreen : AppTheme.statusRed,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            _verified == true ? "Verifikasi Berhasil" : "Verifikasi Gagal",
                            style: AppTheme.heading3.copyWith(
                              color: _verified == true ? AppTheme.statusGreen : AppTheme.statusRed,
                            ),
                          ),
                          const SizedBox(height: 4),

                          if (_confidence != null && _confidence! < 900)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Jarak LBPH: ${_confidence!.toStringAsFixed(1)}",
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _confidence! < 80
                                        ? "Sangat mirip (< 80)"
                                        : _confidence! < 100
                                            ? "Cukup mirip (80-100)"
                                            : "Tidak mirip (> 100)",
                                    style: AppTheme.bodySmall.copyWith(
                                      color: _confidence! < 80
                                          ? AppTheme.statusGreen
                                          : _confidence! < 100
                                              ? AppTheme.statusYellow
                                              : AppTheme.statusRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_statusText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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
                      onPressed: _isCameraInitialized ? _captureAndVerify : null,
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                  ),

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
}
