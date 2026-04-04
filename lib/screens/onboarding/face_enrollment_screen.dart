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

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  CameraDescription? _frontCamera;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
      if (provider.recordingState == VideoRecordingState.idle ||
          provider.recordingState == VideoRecordingState.recording) {
        provider.processCameraImage(
          image,
          _frontCamera!,
          CameraUtils.rotationIntToImageRotation(
              _frontCamera!.sensorOrientation),
        );
      }
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleStartRecording(FaceProvider provider) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));

    _cameraController!.startImageStream((CameraImage image) {
      if (!mounted) return;
      final p = context.read<FaceProvider>();
      if (p.recordingState == VideoRecordingState.recording) {
        p.processCameraImage(
          image,
          _frontCamera!,
          CameraUtils.rotationIntToImageRotation(
              _frontCamera!.sensorOrientation),
        );
      }
    });

    HapticFeedback.mediumImpact();
    await provider.startRecording(_cameraController!);
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
      body: Consumer<FaceProvider>(
        builder: (context, provider, child) {
          final bool isIdle =
              provider.recordingState == VideoRecordingState.idle;
          final bool isRecording =
              provider.recordingState == VideoRecordingState.recording;
          final bool isUploading =
              provider.recordingState == VideoRecordingState.uploading;
          final bool isSuccess =
              provider.recordingState == VideoRecordingState.success;
          final bool isError =
              provider.recordingState == VideoRecordingState.error;

          Color scanColor = AppTheme.primaryOrange;
          if (isIdle || isRecording) {
            if (!provider.isFaceDetected) {
              scanColor = AppTheme.statusRed;
            } else if (provider.allChecksValid) {
              scanColor = AppTheme.statusGreen;
            } else {
              scanColor = AppTheme.statusYellow;
            }
          } else if (isSuccess) {
            scanColor = AppTheme.statusGreen;
          }

          return Stack(
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
                    child:
                        CircularProgressIndicator(color: Colors.white)),

              ScannerOverlay(
                borderColor: scanColor,
                isScanning: isIdle || isRecording,
              ),

              // --- REC indicator ---
              if (isRecording)
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'REC',
                                style: AppTheme.bodySmall
                                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // --- Header + Quality Checklist ---
              Positioned(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                left: 20,
                right: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pendaftaran Wajah",
                      style:
                          AppTheme.heading3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),

                    // Quality checklist chips
                    if (isIdle || isRecording)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildQualityChip(
                            icon: Icons.straighten,
                            label: 'Jarak',
                            isOk: provider.isDistanceOk,
                            isDetected: provider.isFaceDetected,
                          ),
                          _buildQualityChip(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Cahaya',
                            isOk: provider.isBrightnessOk,
                            isDetected: provider.isFaceDetected,
                          ),
                          _buildQualityChip(
                            icon: Icons.face,
                            label: provider.stepLabel,
                            isOk: provider.isPoseValid,
                            isDetected: provider.isFaceDetected,
                          ),
                        ],
                      ),

                    // Status banner for uploading/success/error
                    if (!isIdle && !isRecording)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: ClipRRect(
                          key: ValueKey(provider.recordingState),
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? AppTheme.statusGreen.withOpacity(0.25)
                                    : isError
                                        ? Colors.red.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSuccess
                                      ? AppTheme.statusGreen.withOpacity(0.6)
                                      : isError
                                          ? Colors.red.withOpacity(0.6)
                                          : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(provider),
                                    color: _getStatusColor(provider),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _getStatusText(provider),
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: _getStatusColor(provider),
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

              // --- Instruksi di tengah saat recording ---
              if (isRecording)
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(provider.currentStep),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStepIcon(provider.currentStep),
                          size: 60,
                          color: provider.allChecksValid
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.stepLabel,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: provider.allChecksValid
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                        if (!provider.allChecksValid &&
                            provider.qualityMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                provider.qualityMessage,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.statusYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // --- Panel Bawah ---
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    // Step indicator + progress (saat recording)
                    if (isRecording) ...[
                      _buildStepIndicator(provider),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: provider.stepProgress.clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      provider.allChecksValid
                                          ? AppTheme.statusGreen
                                          : AppTheme.statusYellow,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  provider.allChecksValid
                                      ? 'Merekam...'
                                      : 'Menunggu — ${provider.qualityMessage}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: provider.allChecksValid
                                        ? Colors.white70
                                        : AppTheme.statusYellow,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Uploading state
                    if (isUploading)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                                color: AppTheme.primaryOrange),
                            const SizedBox(height: 16),
                            Text(
                              provider.message,
                              style: AppTheme.bodySmall
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Proses ini membutuhkan beberapa saat...",
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Idle state — tombol mulai rekam
                    if (isIdle)
                      Column(
                        children: [
                          if (provider.qualityMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                provider.qualityMessage,
                                style: AppTheme.bodySmall.copyWith(
                                  color: provider.isFaceDetected
                                      ? AppTheme.statusYellow
                                      : Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          CustomButton(
                            text: "Mulai Rekam",
                            icon: Icons.videocam,
                            backgroundColor: provider.allChecksValid
                                ? AppTheme.statusGreen
                                : AppTheme.primaryDark.withOpacity(0.5),
                            onPressed: provider.allChecksValid
                                ? () => _handleStartRecording(provider)
                                : null,
                          ),
                        ],
                      ),

                    // Success state
                    if (isSuccess)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: CustomButton(
                          text: widget.isOnboarding
                              ? "Lanjut: Tanda Tangan"
                              : "Selesai",
                          icon: widget.isOnboarding
                              ? Icons.arrow_forward
                              : Icons.check,
                          backgroundColor: AppTheme.statusGreen,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (widget.isOnboarding) {
                              context.read<SetupCheckProvider>().reset();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SignatureScreen(isOnboarding: true),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),

                    // Error state
                    if (isError)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage,
                                    style: AppTheme.bodySmall
                                        .copyWith(color: Colors.red[200]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: "Coba Lagi",
                            icon: Icons.refresh,
                            backgroundColor: AppTheme.primaryOrange,
                            onPressed: () {
                              provider.reset();
                              _restartCameraStream();
                            },
                          ),
                        ],
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

  Widget _buildStepIndicator(FaceProvider provider) {
    final steps = [
      (EnrollmentStep.front, 'Depan'),
      (EnrollmentStep.right, 'Kanan'),
      (EnrollmentStep.left, 'Kiri'),
    ];

    final currentIndex = EnrollmentStep.values.indexOf(provider.currentStep);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isCompleted = lineIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.statusGreen
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              final isCompleted = stepIndex < currentIndex;
              final isCurrent = stepIndex == currentIndex;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isCurrent ? 28 : 22,
                    height: isCurrent ? 28 : 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.statusGreen
                          : isCurrent
                              ? AppTheme.primaryOrange
                              : Colors.white.withOpacity(0.2),
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isCurrent ? 13 : 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.$2,
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityChip({
    required IconData icon,
    required String label,
    required bool isOk,
    required bool isDetected,
  }) {
    final color = !isDetected
        ? Colors.white.withOpacity(0.4)
        : isOk
            ? AppTheme.statusGreen
            : AppTheme.statusYellow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk && isDetected ? Icons.check_circle : icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(EnrollmentStep step) {
    switch (step) {
      case EnrollmentStep.front:
        return Icons.face;
      case EnrollmentStep.right:
        return Icons.turn_right;
      case EnrollmentStep.left:
        return Icons.turn_left;
    }
  }

  void _restartCameraStream() {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;

    try {
      if (!_cameraController!.value.isStreamingImages) {
        _cameraController!.startImageStream((CameraImage image) {
          if (!mounted) return;
          final provider = context.read<FaceProvider>();
          provider.processCameraImage(
            image,
            _frontCamera!,
            CameraUtils.rotationIntToImageRotation(
                _frontCamera!.sensorOrientation),
          );
        });
      }
    } catch (_) {}
  }

  String _getStatusText(FaceProvider provider) {
    switch (provider.recordingState) {
      case VideoRecordingState.idle:
        return '';
      case VideoRecordingState.recording:
        return '';
      case VideoRecordingState.uploading:
        return "⏳ Memproses...";
      case VideoRecordingState.success:
        return "✅ ${provider.message}";
      case VideoRecordingState.error:
        return "❌ Gagal";
    }
  }

  IconData _getStatusIcon(FaceProvider provider) {
    switch (provider.recordingState) {
      case VideoRecordingState.idle:
        return Icons.face;
      case VideoRecordingState.recording:
        return Icons.videocam;
      case VideoRecordingState.uploading:
        return Icons.cloud_upload;
      case VideoRecordingState.success:
        return Icons.check_circle;
      case VideoRecordingState.error:
        return Icons.error;
    }
  }

  Color _getStatusColor(FaceProvider provider) {
    switch (provider.recordingState) {
      case VideoRecordingState.idle:
        return Colors.white;
      case VideoRecordingState.recording:
        return Colors.white;
      case VideoRecordingState.uploading:
        return AppTheme.primaryOrange;
      case VideoRecordingState.success:
        return AppTheme.statusGreen;
      case VideoRecordingState.error:
        return Colors.red;
    }
  }
}
