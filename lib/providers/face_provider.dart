import 'dart:io';
import 'dart:ui' show Rect;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../repositories/face_repository.dart';
import '../core/utils/camera_utils.dart';

enum EnrollmentStep { depan, kanan, kiri, bawah, selesai }

// Status feedback real-time ke UI untuk panduan user
enum FaceStatus {
  noFace,       // Tidak ada wajah terdeteksi
  tooFar,       // Wajah terlalu jauh (kotak kecil)
  tooClose,     // Wajah terlalu dekat (kotak besar)
  outOfFrame,   // Wajah tidak di dalam area scan
  wrongPose,    // Wajah ada & di frame, tapi pose salah
  holding,      // Pose benar, sedang menghitung mundur
  ready,        // Siap capture (internal, langsung ambil foto)
}

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
  FaceStatus _faceStatus = FaceStatus.noFace;

  // Hold timer: pose harus dipertahankan selama ini sebelum capture
  static const int _holdDurationMs = 1500;
  DateTime? _poseValidSince;
  double _holdProgress = 0.0; // 0.0 - 1.0

  File? _fotoDepan;
  File? _fotoKanan;
  File? _fotoKiri;
  File? _fotoBawah;

  EnrollmentStep get currentStep => _currentStep;
  bool get isUploading => _isUploading;
  String get instructionText => _instructionText;
  FaceStatus get faceStatus => _faceStatus;
  double get holdProgress => _holdProgress;

  void reset() {
    _currentStep = EnrollmentStep.depan;
    _instructionText = "Hadapkan wajah lurus ke depan";
    _fotoDepan = null;
    _fotoKanan = null;
    _fotoKiri = null;
    _fotoBawah = null;
    _isProcessing = false;
    _isUploading = false;
    _faceStatus = FaceStatus.noFace;
    _poseValidSince = null;
    _holdProgress = 0.0;
    notifyListeners();
  }

  Future<void> processCameraImage(
    CameraImage image,
    CameraDescription camera,
    InputImageRotation rotation, {
    // Ukuran kotak scan dalam koordinat layar (0.0 - 1.0)
    double scanBoxLeft = 0.125,
    double scanBoxRight = 0.875,
    double scanBoxTop = 0.275,
    double scanBoxBottom = 0.725,
  }) async {
    if (_isProcessing || _currentStep == EnrollmentStep.selesai) return;

    _isProcessing = true;

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image: image,
        camera: camera,
        rotation: rotation,
      );

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _updateFaceStatus(FaceStatus.noFace);
        _resetHoldTimer();
      } else {
        final Face face = faces.first;
        _validateAndCheckPose(face, image, scanBoxLeft, scanBoxRight, scanBoxTop, scanBoxBottom);
      }
    } catch (e) {
      debugPrint("Error processing face: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _validateAndCheckPose(
    Face face,
    CameraImage image,
    double boxLeft,
    double boxRight,
    double boxTop,
    double boxBottom,
  ) {
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    // Bounding box dari ML Kit (dalam koordinat gambar - KAMERA DEPAN MIRROR)
    final Rect bb = face.boundingBox;

    // Normalisasi ke 0.0 - 1.0
    // Untuk kamera depan di Android, X perlu di-flip karena kamera mirror
    final double faceLeft   = 1.0 - (bb.right / imgW);
    final double faceRight  = 1.0 - (bb.left  / imgW);
    final double faceTop    = bb.top    / imgH;
    final double faceBottom = bb.bottom / imgH;

    final double faceWidth  = faceRight - faceLeft;

    // --- Validasi Jarak (ukuran wajah) ---
    // Wajah ideal: lebarnya 35% - 65% dari lebar frame
    const double minFaceRatio = 0.30;
    const double maxFaceRatio = 0.70;

    if (faceWidth < minFaceRatio) {
      _updateFaceStatus(FaceStatus.tooFar);
      _resetHoldTimer();
      return;
    }
    if (faceWidth > maxFaceRatio) {
      _updateFaceStatus(FaceStatus.tooClose);
      _resetHoldTimer();
      return;
    }

    // --- Validasi Posisi dalam Kotak Scan ---
    // Center wajah harus berada di dalam kotak scan (dengan toleransi 10%)
    final double faceCenterX = (faceLeft + faceRight) / 2;
    final double faceCenterY = (faceTop + faceBottom) / 2;

    const double tolerance = 0.10;
    final bool inBox = faceCenterX >= (boxLeft - tolerance) &&
        faceCenterX <= (boxRight + tolerance) &&
        faceCenterY >= (boxTop - tolerance) &&
        faceCenterY <= (boxBottom + tolerance);

    if (!inBox) {
      _updateFaceStatus(FaceStatus.outOfFrame);
      _resetHoldTimer();
      return;
    }

    // --- Validasi Pose ---
    final bool isPoseValid = _isPoseValid(face);

    if (!isPoseValid) {
      _updateFaceStatus(FaceStatus.wrongPose);
      _resetHoldTimer();
      return;
    }

    // --- Pose valid: jalankan hold timer ---
    _tickHoldTimer();
  }

  bool _isPoseValid(Face face) {
    const double thresholdFront = 10.0;
    const double thresholdSide  = 15.0;
    const double thresholdDown  = 5.0;

    final double? rotY = face.headEulerAngleY;
    final double? rotX = face.headEulerAngleX;

    if (rotY == null || rotX == null) return false;

    switch (_currentStep) {
      case EnrollmentStep.depan:
        return rotY.abs() < thresholdFront && rotX.abs() < thresholdFront;
      case EnrollmentStep.kanan:
        return rotY < -thresholdSide;
      case EnrollmentStep.kiri:
        return rotY > thresholdSide;
      case EnrollmentStep.bawah:
        return rotX < -thresholdDown && rotY.abs() < thresholdFront;
      default:
        return false;
    }
  }

  void _tickHoldTimer() {
    final now = DateTime.now();

    if (_poseValidSince == null) {
      _poseValidSince = now;
    }

    final elapsed = now.difference(_poseValidSince!).inMilliseconds;
    _holdProgress = (elapsed / _holdDurationMs).clamp(0.0, 1.0);

    _updateFaceStatus(FaceStatus.holding);

    if (elapsed >= _holdDurationMs) {
      // Capture!
      _poseValidSince = null;
      _holdProgress = 0.0;
      _captureImage();
    }
  }

  void _resetHoldTimer() {
    if (_poseValidSince != null || _holdProgress > 0) {
      _poseValidSince = null;
      _holdProgress = 0.0;
      notifyListeners();
    }
  }

  void _updateFaceStatus(FaceStatus status) {
    if (_faceStatus != status) {
      _faceStatus = status;
      notifyListeners();
    }
  }

  void _captureImage() {
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

    _faceStatus = FaceStatus.noFace;
    notifyListeners();

    // Cooldown setelah capture agar tidak langsung re-trigger
    Future.delayed(const Duration(milliseconds: 800), () {
      _isProcessing = false;
    });
  }

  void saveCapturedFile(File file) {
    if (_fotoDepan == null) {
      _fotoDepan = file;
    } else if (_fotoKanan == null) {
      _fotoKanan = file;
    } else if (_fotoKiri == null) {
      _fotoKiri = file;
    } else if (_fotoBawah == null) {
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
    _faceDetector.close();
    super.dispose();
  }
}
