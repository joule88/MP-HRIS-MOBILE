import 'package:flutter/material.dart';
import '../repositories/face_repository.dart';
import '../repositories/signature_repository.dart';

class SetupCheckProvider extends ChangeNotifier {
  final FaceRepository _faceRepository = FaceRepository();
  final SignatureRepository _signatureRepository = SignatureRepository();

  bool _isLoading = false;
  bool _hasFace = false;
  bool _hasSignature = false;

  bool get isLoading => _isLoading;
  bool get hasFace => _hasFace;
  bool get hasSignature => _hasSignature;

  Future<void> checkSetup() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _faceRepository.getFaceStatus(),
        _signatureRepository.getActiveSignature(),
      ]);

      final faceData = results[0];
      final signatureData = results[1];

      // Backend mengembalikan: { is_registered: bool, status: 'verified'|'pending'|'not_registered' }
      // Dianggap sudah punya wajah jika is_registered = true (sudah upload foto, meski pending approval)
      _hasFace = faceData['is_registered'] == true;
      _hasSignature = signatureData['success'] == true && signatureData['data'] != null;
    } catch (e) {
      _hasFace = false;
      _hasSignature = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _hasFace = false;
    _hasSignature = false;
  }
}
