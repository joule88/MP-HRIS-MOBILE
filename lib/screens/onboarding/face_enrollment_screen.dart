import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/face_provider.dart';
import '../../providers/setup_check_provider.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/scanner_overlay.dart';
import '../../core/utils/camera_utils.dart';
import '../../core/theme.dart';
import '../profile/signature_screen.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  final bool isOnboarding;

  const FaceEnrollmentScreen({this.isOnboarding = false, super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  CameraDescription? _frontCamera;
  int _lastStepIndex = -1;

  // Koordinat kotak scan (0.0 - 1.0) — harus cocok dengan _ScannerPainter
  // ScannerOverlay: lebar 75% (0.125 - 0.875), tinggi 45% dari tengah (0.275 - 0.725)
  static const double _boxLeft   = 0.125;
  static const double _boxRight  = 0.875;
  static const double _boxTop    = 0.275;
  static const double _boxBottom = 0.725;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceProvider>().reset();
    });
  }

  Future<void> _initializeCamera() async {
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

    _cameraController!.startImageStream((CameraImage image) {
      if (!mounted) return;

      final provider = context.read<FaceProvider>();

      provider.processCameraImage(
        image,
        _frontCamera!,
        CameraUtils.rotationIntToImageRotation(_frontCamera!.sensorOrientation),
        scanBoxLeft:   _boxLeft,
        scanBoxRight:  _boxRight,
        scanBoxTop:    _boxTop,
        scanBoxBottom: _boxBottom,
      );
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Teks panduan berdasarkan FaceStatus
  String _getStatusText(FaceProvider provider) {
    switch (provider.faceStatus) {
      case FaceStatus.noFace:
        return provider.instructionText;
      case FaceStatus.tooFar:
        return "⬆️ Dekatkan wajah ke kamera";
      case FaceStatus.tooClose:
        return "⬇️ Jauhkan wajah dari kamera";
      case FaceStatus.outOfFrame:
        return "📦 Arahkan wajah ke dalam kotak";
      case FaceStatus.wrongPose:
        return provider.instructionText;
      case FaceStatus.holding:
        return "✅ Tahan posisi...";
      case FaceStatus.ready:
        return "📸 Mengambil foto...";
    }
  }

  // Warna border kotak berdasarkan status
  Color _getBorderColor(FaceProvider provider) {
    if (provider.currentStep == EnrollmentStep.selesai) {
      return AppTheme.statusGreen;
    }
    switch (provider.faceStatus) {
      case FaceStatus.holding:
        return AppTheme.statusGreen;
      case FaceStatus.outOfFrame:
      case FaceStatus.tooFar:
      case FaceStatus.tooClose:
        return AppTheme.statusRed;
      default:
        return AppTheme.primaryOrange;
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
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<FaceProvider>(
        builder: (context, provider, child) {
          // Deteksi step baru → ambil foto
          if (provider.currentStep.index > _lastStepIndex && _lastStepIndex != -1) {
            HapticFeedback.lightImpact();
            _takePictureAndSave(provider);
          }
          if (_lastStepIndex != provider.currentStep.index) {
            _lastStepIndex = provider.currentStep.index;
          }

          final bool isComplete  = provider.currentStep == EnrollmentStep.selesai;
          final bool isHolding   = provider.faceStatus == FaceStatus.holding;
          final Color scanColor  = _getBorderColor(provider);

          return Stack(
            children: [
              // --- Preview Kamera ---
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
                const Center(child: CircularProgressIndicator(color: Colors.white)),

              // --- Overlay Kotak Scan ---
              ScannerOverlay(
                borderColor: scanColor,
                isScanning: !isComplete && !provider.isUploading && !isHolding,
              ),

              // --- Hold Progress Ring (di tengah kotak scan) ---
              if (isHolding && !isComplete)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: provider.holdProgress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.statusGreen),
                      ),
                    ),
                  ),
                ),

              // --- Banner Instruksi Atas ---
              Positioned(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      "Pendaftaran Wajah",
                      style: AppTheme.heading3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: ClipRRect(
                        key: ValueKey(provider.faceStatus),
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isHolding
                                  ? AppTheme.statusGreen.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isHolding
                                    ? AppTheme.statusGreen.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isComplete
                                      ? Icons.check_circle
                                      : isHolding
                                          ? Icons.timer
                                          : Icons.face,
                                  color: isComplete
                                      ? AppTheme.statusGreen
                                      : isHolding
                                          ? AppTheme.statusGreen
                                          : AppTheme.primaryOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isComplete
                                        ? provider.instructionText
                                        : _getStatusText(provider),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: isComplete
                                          ? AppTheme.statusGreen
                                          : isHolding
                                              ? AppTheme.statusGreen
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Panel Bawah: Progress Steps & Tombol Selesai ---
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    if (provider.isUploading)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: AppTheme.primaryOrange),
                            const SizedBox(height: 12),
                            Text("Mengunggah data wajah...", style: AppTheme.bodySmall.copyWith(color: Colors.white)),
                          ],
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(4, (index) {
                                final isActive = index == provider.currentStep.index;
                                final isPassed = index < provider.currentStep.index;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: isActive ? 24 : 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isPassed
                                        ? AppTheme.statusGreen
                                        : (isActive ? AppTheme.statusYellow : Colors.white.withOpacity(0.3)),
                                    boxShadow: isActive || isPassed
                                        ? [
                                            BoxShadow(
                                              color: (isPassed ? AppTheme.statusGreen : AppTheme.statusYellow).withOpacity(0.6),
                                              blurRadius: 8,
                                            )
                                          ]
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),

                    if (isComplete)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: CustomButton(
                          text: widget.isOnboarding ? "Lanjut: Tanda Tangan" : "Selesai",
                          icon: widget.isOnboarding ? Icons.arrow_forward : Icons.check,
                          backgroundColor: AppTheme.statusGreen,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (widget.isOnboarding) {
                              context.read<SetupCheckProvider>().reset();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignatureScreen(isOnboarding: true),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _takePictureAndSave(FaceProvider provider) async {
    try {
      await _cameraController?.stopImageStream();

      final XFile file = await _cameraController!.takePicture();
      provider.saveCapturedFile(File(file.path));

      await _cameraController?.startImageStream((CameraImage image) {
        if (!mounted) return;
        provider.processCameraImage(
          image,
          _frontCamera!,
          CameraUtils.rotationIntToImageRotation(_frontCamera!.sensorOrientation),
          scanBoxLeft:   _boxLeft,
          scanBoxRight:  _boxRight,
          scanBoxTop:    _boxTop,
          scanBoxBottom: _boxBottom,
        );
      });
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }
}
