import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../repositories/face_repository.dart';
import '../core/utils/camera_utils.dart';

enum VideoRecordingState { idle, recording, uploading, success, error }

enum FaceDetectionStatus { noFace, detected }

enum EnrollmentStep { front, right, left }

class FaceProvider with ChangeNotifier {
  final FaceRepository _repository = FaceRepository();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  VideoRecordingState _recordingState = VideoRecordingState.idle;
  FaceDetectionStatus _faceDetectionStatus = FaceDetectionStatus.noFace;
  File? _videoFile;
  String _message = '';
  String _errorMessage = '';
  bool _isProcessingFrame = false;

  // Guided enrollment
  EnrollmentStep _currentStep = EnrollmentStep.front;
  double _headEulerAngleY = 0.0;
  bool _isPoseValid = false;
  double _faceRatio = 0.0;
  bool _isDistanceOk = false;
  double _brightness = 0.0;
  bool _isBrightnessOk = false;
  double _stepProgress = 0.0;
  Timer? _progressTimer;

  static const double _frontDuration = 4.0;
  static const double _sideDuration = 3.0;
  static const double _tickInterval = 100;

  VideoRecordingState get recordingState => _recordingState;
  FaceDetectionStatus get faceDetectionStatus => _faceDetectionStatus;
  String get message => _message;
  String get errorMessage => _errorMessage;
  bool get isFaceDetected =>
      _faceDetectionStatus == FaceDetectionStatus.detected;

  EnrollmentStep get currentStep => _currentStep;
  double get headEulerAngleY => _headEulerAngleY;
  bool get isPoseValid => _isPoseValid;
  double get faceRatio => _faceRatio;
  bool get isDistanceOk => _isDistanceOk;
  double get brightness => _brightness;
  bool get isBrightnessOk => _isBrightnessOk;
  double get stepProgress => _stepProgress;

  bool get allChecksValid =>
      isFaceDetected && _isPoseValid && _isDistanceOk && _isBrightnessOk;

  String get qualityMessage {
    if (!isFaceDetected) return 'Arahkan wajah ke dalam bingkai';
    if (_faceRatio < 0.20) return 'Terlalu jauh, dekatkan wajah ke kamera';
    if (_faceRatio > 0.70) return 'Terlalu dekat, mundur sedikit';
    if (!_isBrightnessOk) return 'Pencahayaan kurang, cari tempat lebih terang';
    if (!_isPoseValid) {
      switch (_currentStep) {
        case EnrollmentStep.front:
          return 'Hadapkan wajah ke depan';
        case EnrollmentStep.right:
          return 'Toleh ke kanan';
        case EnrollmentStep.left:
          return 'Toleh ke kiri';
      }
    }
    return '';
  }

  String get stepLabel {
    switch (_currentStep) {
      case EnrollmentStep.front:
        return 'Hadap Depan';
      case EnrollmentStep.right:
        return 'Toleh Kanan';
      case EnrollmentStep.left:
        return 'Toleh Kiri';
    }
  }

  void reset() {
    _recordingState = VideoRecordingState.idle;
    _faceDetectionStatus = FaceDetectionStatus.noFace;
    _videoFile = null;
    _message = '';
    _errorMessage = '';
    _isProcessingFrame = false;
    _currentStep = EnrollmentStep.front;
    _headEulerAngleY = 0.0;
    _isPoseValid = false;
    _faceRatio = 0.0;
    _isDistanceOk = false;
    _brightness = 0.0;
    _isBrightnessOk = false;
    _stepProgress = 0.0;
    _progressTimer?.cancel();
    _progressTimer = null;
    notifyListeners();
  }

  Future<void> startRecording(CameraController controller) async {
    if (_recordingState == VideoRecordingState.recording) return;

    try {
      await controller.startVideoRecording();
      _recordingState = VideoRecordingState.recording;
      _currentStep = EnrollmentStep.front;
      _stepProgress = 0.0;
      _message = 'Hadap Depan';
      notifyListeners();

      _startProgressTimer(controller);
    } catch (e) {
      _recordingState = VideoRecordingState.error;
      _errorMessage = 'Gagal memulai rekaman: $e';
      notifyListeners();
    }
  }

  void _startProgressTimer(CameraController controller) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      Duration(milliseconds: _tickInterval.toInt()),
      (timer) {
        if (_recordingState != VideoRecordingState.recording) {
          timer.cancel();
          return;
        }

        if (allChecksValid) {
          final duration = _currentStep == EnrollmentStep.front
              ? _frontDuration
              : _sideDuration;
          final increment = (_tickInterval / 1000) / duration;
          _stepProgress += increment;
        }

        if (_stepProgress >= 1.0) {
          _advanceStep(controller);
        }

        notifyListeners();
      },
    );
  }

  void _advanceStep(CameraController controller) {
    switch (_currentStep) {
      case EnrollmentStep.front:
        _currentStep = EnrollmentStep.right;
        _stepProgress = 0.0;
        _isPoseValid = false;
        _message = 'Toleh Kanan';
        break;
      case EnrollmentStep.right:
        _currentStep = EnrollmentStep.left;
        _stepProgress = 0.0;
        _isPoseValid = false;
        _message = 'Toleh Kiri';
        break;
      case EnrollmentStep.left:
        _progressTimer?.cancel();
        stopRecording(controller);
        break;
    }
  }

  Future<void> stopRecording(CameraController controller) async {
    _progressTimer?.cancel();

    if (!controller.value.isRecordingVideo) return;

    try {
      final XFile video = await controller.stopVideoRecording();
      _videoFile = File(video.path);
      _message = 'Rekaman selesai. Mengunggah...';
      notifyListeners();

      await submitVideo();
    } catch (e) {
      _recordingState = VideoRecordingState.error;
      _errorMessage = 'Gagal menghentikan rekaman: $e';
      notifyListeners();
    }
  }

  Future<void> submitVideo() async {
    if (_videoFile == null) {
      _recordingState = VideoRecordingState.error;
      _errorMessage = 'File video tidak ditemukan.';
      notifyListeners();
      return;
    }

    _recordingState = VideoRecordingState.uploading;
    _message = 'Mengunggah & memproses video...';
    notifyListeners();

    try {
      await _repository.enrollFace(videoFile: _videoFile!);
      _recordingState = VideoRecordingState.success;
      _message = 'Pendaftaran Wajah Berhasil!';
    } catch (e) {
      _recordingState = VideoRecordingState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void processCameraImage(
    CameraImage image,
    CameraDescription camera,
    InputImageRotation rotation,
  ) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      _brightness = BrightnessUtils.calculateBrightness(image);
      _isBrightnessOk = _brightness > 60;

      final inputImage = CameraUtils.inputImageFromCameraImage(
        image: image,
        camera: camera,
        rotation: rotation,
      );

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        _faceDetectionStatus = FaceDetectionStatus.detected;

        _headEulerAngleY = face.headEulerAngleY ?? 0.0;

        final imageWidth = image.width.toDouble();
        final box = face.boundingBox;
        _faceRatio = box.width / imageWidth;
        _isDistanceOk = _faceRatio >= 0.20 && _faceRatio <= 0.70;

        switch (_currentStep) {
          case EnrollmentStep.front:
            _isPoseValid = _headEulerAngleY.abs() < 15;
            break;
          case EnrollmentStep.right:
            _isPoseValid = _headEulerAngleY < -20;
            break;
          case EnrollmentStep.left:
            _isPoseValid = _headEulerAngleY > 20;
            break;
        }
      } else {
        _faceDetectionStatus = FaceDetectionStatus.noFace;
        _isPoseValid = false;
        _isDistanceOk = false;
        _faceRatio = 0.0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error processing face: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  Map<String, dynamic> _faceStatus2 = {};
  Map<String, dynamic> get faceStatus2 => _faceStatus2;

  Future<void> loadFaceStatus() async {
    try {
      final status = await _repository.getFaceStatus();
      _faceStatus2 = status;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading face status: $e");
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _faceDetector.close();
    super.dispose();
  }
}
