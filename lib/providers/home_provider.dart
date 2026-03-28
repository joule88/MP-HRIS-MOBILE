import 'package:flutter/material.dart';
import '../../repositories/home_repository.dart';
import '../../models/user_model.dart';
import '../../models/presensi_model.dart';
import '../../models/announcement_model.dart';
import '../../services/reminder_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  UserModel? user;
  int poinLembur = 0;
  PresensiModel? presensiToday;
  List<AnnouncementModel> pengumumanList = [];
  int sisaCuti = 0;
  int izinCount = 0;
  int alphaCount = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _repository.getDashboardData();
      user = data['user'];
      poinLembur = data['poin'];
      presensiToday = data['presensi_today'];
      pengumumanList = data['pengumuman_list'];
      sisaCuti = data['sisa_cuti'] ?? 0;
      izinCount = data['izin_count'] ?? 0;
      alphaCount = data['alpha_count'] ?? 0;
      _isLoading = false;

      _scheduleAttendanceReminders();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  void _scheduleAttendanceReminders() {
    if (presensiToday == null) return;
    final jamMasuk = presensiToday!.jadwalJamMasuk;
    final jamPulang = presensiToday!.jadwalJamPulang;
    if (jamMasuk == null || jamPulang == null) return;

    ReminderService().scheduleWeeklyReminders(
      jadwalJamMasuk: jamMasuk,
      jadwalJamPulang: jamPulang,
      sudahAbsenMasuk: presensiToday!.sudahAbsenMasuk,
      sudahAbsenPulang: presensiToday!.sudahAbsenPulang,
    );
  }
}
