import 'package:flutter/material.dart';
import '../repositories/notifikasi_repository.dart';
import '../../models/notifikasi_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotifikasiRepository _repository = NotifikasiRepository();

  List<NotifikasiModel> notifications = [];
  int unreadCount = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      notifications = await _repository.getNotifikasi();
      unreadCount = notifications.where((n) => !n.isRead).length;
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    await _repository.markAsRead(id);
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = NotifikasiModel(
        id: notifications[idx].id,
        judul: notifications[idx].judul,
        pesan: notifications[idx].pesan,
        tipe: notifications[idx].tipe,
        isRead: true,
        createdAt: notifications[idx].createdAt,
        data: notifications[idx].data,
      );
      unreadCount = notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    notifications = notifications.map((n) => NotifikasiModel(
      id: n.id,
      judul: n.judul,
      pesan: n.pesan,
      tipe: n.tipe,
      isRead: true,
      createdAt: n.createdAt,
      data: n.data,
    )).toList();
    unreadCount = 0;
    notifyListeners();
  }
}
