import 'package:flutter/material.dart';
import '../../repositories/pengajuan_repository.dart';
import '../../repositories/lembur_repository.dart';
import '../../repositories/signature_repository.dart';
import '../../models/pengajuan_model.dart';

class PengajuanProvider extends ChangeNotifier {
  final PengajuanRepository _repository = PengajuanRepository();
  final LemburRepository _lemburRepository = LemburRepository();
  final SignatureRepository _signatureRepository = SignatureRepository();

  List<PengajuanModel> listPengajuan = [];
  bool isLoading = false;
  int selectedTabIndex = 0;
  bool hasSignature = false;

  Future<void> checkSignatureStatus() async {
    final result = await _signatureRepository.getActiveSignature();
    hasSignature = result['success'] == true;
    notifyListeners();
  }

  void setTabIndex(int index) {
    selectedTabIndex = index;
    fetchPengajuan();
    notifyListeners();
  }

  Future<void> fetchPengajuan() async {
    isLoading = true;
    notifyListeners();

    try {
      String status = 'approved';
      if (selectedTabIndex == 1) status = 'pending';
      if (selectedTabIndex == 2) status = 'rejected';

      final submissions = await _repository.getPengajuan(status: status);
      print('📋 Submissions count: ${submissions.length}');

      final lemburResult = await _lemburRepository.getLemburHistory();
      print('🔥 Lembur API result: $lemburResult');

      List<PengajuanModel> lemburList = [];
      if (lemburResult['success'] == true && lemburResult['data'] != null) {
        print('✅ Lembur success = true');
        final dynamic lemburData = lemburResult['data'];
        print('📦 Lembur data type: ${lemburData.runtimeType}');
        print('📦 Lembur data: $lemburData');

        List rawData = [];

        if (lemburData is List) {
          rawData = lemburData;
          print('✅ Detected as List, count: ${rawData.length}');
        } else if (lemburData is Map && lemburData['data'] != null) {
          rawData = lemburData['data'];
          print('✅ Detected as Map with data, count: ${rawData.length}');
        }

        print('🔍 Raw lembur count before filter: ${rawData.length}');

        lemburList = rawData
            .map((json) => PengajuanModel.fromLemburJson(json))
            .where((item) {
              print('🔍 Lembur item status: ${item.status}, target: $status');
              return item.status == status;
            })
            .toList();

        print('📊 Lembur count after filter: ${lemburList.length}');
      } else {
        print('❌ Lembur failed or no data');
        print('   success: ${lemburResult['success']}');
        print('   data: ${lemburResult['data']}');
      }

      listPengajuan = [...submissions, ...lemburList];
      print('📊 Total pengajuan count: ${listPengajuan.length}');
      listPengajuan.sort((a, b) => b.tanggalPengajuan.compareTo(a.tanggalPengajuan));

    } catch (e, stack) {
      print('❌ Error in fetchPengajuan: $e');
      print(stack);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitCuti(Map<String, dynamic> data) async {
     return await _submitGeneric('Cuti', data);
  }

  Future<bool> submitSakit(Map<String, dynamic> data) async {
     return await _submitGeneric('Sakit', data);
  }

  Future<bool> submitIzin(Map<String, dynamic> data) async {
     return await _submitGeneric('Izin', data);
  }

  Future<bool> submitLembur(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      final dateParts = (data['date'] as String).split('/');
      final tanggalLembur = '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';

      final result = await _lemburRepository.submitLembur(
        tanggalLembur: tanggalLembur,
        jamMulai: _convertTo24Hour(data['start_time']),
        jamSelesai: _convertTo24Hour(data['end_time']),
        keterangan: data['reason'],
        idKompensasi: data['id_kompensasi'],
      );

      return result['success'] == true;
    } catch(e) {
      print('Error submitting lembur: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _convertTo24Hour(String time12h) {
    if (!time12h.contains('AM') && !time12h.contains('PM')) {
      return time12h;
    }

    final parts = time12h.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    final period = parts[1];

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  Future<bool> _submitGeneric(String type, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      return await _repository.submitPengajuan(type, data);
    } catch(e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
