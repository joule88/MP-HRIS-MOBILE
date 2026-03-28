import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../repositories/home_repository.dart';

class CalendarProvider extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> get schedules => _schedules;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMonthlySchedule(int month, int year) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMonthlySchedule(month, year);
      _schedules = result;
    } catch (e) {
      _errorMessage = e.toString();
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleModel? getScheduleByDate(DateTime date) {
    if (_schedules.isEmpty) return null;

    String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      return _schedules.firstWhere((s) => s.tanggal == dateKey);
    } catch (e) {
      return null;
    }
  }

  void clearData() {
    _schedules = [];
    notifyListeners();
  }
}
