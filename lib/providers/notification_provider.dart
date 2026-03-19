import 'package:flutter/material.dart';
import '../repositories/home_repository.dart';
import '../models/announcement_model.dart';

class NotificationProvider extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  List<AnnouncementModel> notifications = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getPengumuman();
      notifications = data;
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
