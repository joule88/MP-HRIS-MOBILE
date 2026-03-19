import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../repositories/face_repository.dart';
import '../core/utils/camera_utils.dart';

enum EnrollmentStep { depan, kanan, kiri, bawah, selesai }

class FaceProvider with ChangeNotifier {
  final FaceRepository _repository = FaceRepository();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  EnrollmentStep _currentStep = EnrollmentStep.depan;
  bool _isProcessing = false;
  bool _isUploading = false;
  String _instructionText = "Hadapkan wajah lurus ke depan";

  File? _fotoDepan;
  File? _fotoKanan;
  File? _fotoKiri;
  File? _fotoBawah;

  EnrollmentStep get currentStep => _currentStep;
  bool get isUploading => _isUploading;
  String get instructionText => _instructionText;

  void reset() {
    _currentStep = EnrollmentStep.depan;
    _instructionText = "Hadapkan wajah lurus ke depan";
    _fotoDepan = null;
    _fotoKanan = null;
    _fotoKiri = null;
    _fotoBawah = null;
    _isProcessing = false;
    _isUploading = false;
    notifyListeners();
  }

  Future<void> processCameraImage(CameraImage image, CameraDescription camera, InputImageRotation rotation) async {
    if (_isProcessing || _currentStep == EnrollmentStep.selesai) return;

    _isProcessing = true;

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image: image,
        camera: camera,
        rotation: rotation,
      );

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final Face face = faces.first;
        _checkPoseAndCapture(face, image);
      } else {
      }
    } catch (e) {
      debugPrint("Error processing face: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _checkPoseAndCapture(Face face, CameraImage originalImage) async {
    const double thresholdFront = 10.0;
    const double thresholdSide = 15.0;
    const double thresholdDown = 5.0;

    double? rotY = face.headEulerAngleY;
    double? rotX = face.headEulerAngleX;

    debugPrint("ROT X (Atas/Bawah): $rotX | ROT Y (Kiri/Kanan): $rotY");

    if (rotY == null || rotX == null) return;

    bool isPoseValid = false;

    switch (_currentStep) {
      case EnrollmentStep.depan:
        if (rotY.abs() < thresholdFront && rotX.abs() < thresholdFront) {
          isPoseValid = true;
        }
        break;
      case EnrollmentStep.kanan:
        if (rotY < -thresholdSide) {
           isPoseValid = true;
        }
        break;
      case EnrollmentStep.kiri:
        if (rotY > thresholdSide) {
          isPoseValid = true;
        }
        break;
      case EnrollmentStep.bawah:
        bool isLookingForward = rotY.abs() < thresholdFront;

        if (rotX < -thresholdDown && isLookingForward) {
          isPoseValid = true;
        }
        break;
      default:
        break;
    }

    if (isPoseValid) {
      await _captureImage(originalImage);
    }
  }

  Future<void> _captureImage(CameraImage image) async {
    _isProcessing = true;

    if (_currentStep == EnrollmentStep.depan) {
      _currentStep = EnrollmentStep.kanan;
      _instructionText = "Putar wajah perlahan ke KANAN";
    } else if (_currentStep == EnrollmentStep.kanan) {
      _currentStep = EnrollmentStep.kiri;
      _instructionText = "Putar wajah perlahan ke KIRI";
    } else if (_currentStep == EnrollmentStep.kiri) {
      _currentStep = EnrollmentStep.bawah;
      _instructionText = "Tundukkan kepala ke BAWAH";
    } else if (_currentStep == EnrollmentStep.bawah) {
      _currentStep = EnrollmentStep.selesai;
      _instructionText = "Data lengkap. Mengunggah...";
    }

    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _isProcessing = false;
  }

  void saveCapturedFile(File file) {
    if (_fotoDepan == null) _fotoDepan = file;
    else if (_fotoKanan == null) _fotoKanan = file;
    else if (_fotoKiri == null) _fotoKiri = file;
    else if (_fotoBawah == null) {
      _fotoBawah = file;
      if (_currentStep == EnrollmentStep.selesai) {
         submitEnrollment();
      }
    }
  }

  Future<void> submitEnrollment() async {
    if (_fotoDepan == null || _fotoKanan == null || _fotoKiri == null || _fotoBawah == null) {
      _instructionText = "Gagal: Foto tidak lengkap.";
      notifyListeners();
      return;
    }

    _isUploading = true;
    notifyListeners();

    try {
      await _repository.enrollFace(
        fotoDepan: _fotoDepan!,
        fotoKanan: _fotoKanan!,
        fotoKiri: _fotoKiri!,
        fotoBawah: _fotoBawah!,
      );
      _instructionText = "Pendaftaran Berhasil!";
    } catch (e) {
      _instructionText = "Gagal Upload: ${e.toString()}";
      _currentStep = EnrollmentStep.depan;
      _fotoDepan = null;
      _fotoKanan = null;
      _fotoKiri = null;
      _fotoBawah = null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _faceStatus = {};
  Map<String, dynamic> get faceStatus => _faceStatus;

  Future<void> loadFaceStatus() async {
    try {
      final status = await _repository.getFaceStatus();
      _faceStatus = status;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading face status: $e");
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
