import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../repositories/signature_repository.dart';
import '../models/tanda_tangan_model.dart';

class SignatureProvider extends ChangeNotifier {
  final SignatureRepository _repository = SignatureRepository();

  TandaTanganModel? currentSignature;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchSignature() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getActiveSignature();
      if (result['success'] == true && result['data'] != null) {
        currentSignature = TandaTanganModel.fromJson(result['data']);
      } else {
        currentSignature = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      currentSignature = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadSignature(Uint8List pngBytes) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.uploadSignature(pngBytes);
      if (result['success'] == true) {
        await fetchSignature();
        return true;
      }
      errorMessage = result['message'];
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSignature() async {
    if (currentSignature == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.deleteSignature(currentSignature!.id);
      if (result['success'] == true) {
        currentSignature = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
