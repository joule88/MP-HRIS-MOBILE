import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/face_provider.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/scanner_overlay.dart';
import '../../core/utils/camera_utils.dart';
import '../../core/theme.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  CameraDescription? _frontCamera;
  int _lastStepIndex = -1;

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
        CameraUtils.rotationIntToImageRotation(_frontCamera!.sensorOrientation)
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
          if (provider.currentStep.index > _lastStepIndex && _lastStepIndex != -1) {
             HapticFeedback.lightImpact();
             _takePictureAndSave(provider);
          }
          if (_lastStepIndex != provider.currentStep.index) {
             _lastStepIndex = provider.currentStep.index;
          }

          final bool isComplete = provider.currentStep == EnrollmentStep.selesai;

          return Stack(
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
                const Center(child: CircularProgressIndicator(color: Colors.white)),

              ScannerOverlay(
                borderColor: isComplete ? AppTheme.statusGreen : AppTheme.primaryOrange,
                isScanning: !isComplete && !provider.isUploading,
              ),

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isComplete ? Icons.check_circle : Icons.face,
                                color: isComplete ? AppTheme.statusGreen : AppTheme.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  provider.instructionText,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: isComplete ? AppTheme.statusGreen : Colors.white,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                          text: "Selesai",
                          icon: Icons.check,
                          backgroundColor: AppTheme.statusGreen,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
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
            CameraUtils.rotationIntToImageRotation(_frontCamera!.sensorOrientation)
          );
      });
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }
}
