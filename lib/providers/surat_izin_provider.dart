import 'package:flutter/material.dart';
import '../repositories/surat_izin_repository.dart';
import '../models/surat_izin_model.dart';

class SuratIzinProvider extends ChangeNotifier {
  final SuratIzinRepository _repository = SuratIzinRepository();

  List<SuratIzinModel> listSurat = [];
  SuratIzinModel? selectedSurat;
  bool isLoading = false;
  bool isLoadingDetail = false;
  String? errorMessage;

  Future<void> fetchSurat() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      listSurat = await _repository.getSuratIzin();
    } catch (e) {
      errorMessage = e.toString();
      listSurat = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(String id) async {
    isLoadingDetail = true;
    notifyListeners();

    try {
      selectedSurat = await _repository.getSuratIzinDetail(id);
    } catch (e) {
      selectedSurat = null;
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createSurat({
    required String idIzin,
    required String isiSurat,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.createSuratIzin(
        idIzin: idIzin,
        isiSurat: isiSurat,
      );

      if (result['success'] == true) {
        await fetchSurat();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
