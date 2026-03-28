import 'dart:io';
import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart';
import '../../core/cache_manager.dart';
import '../../services/reminder_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);

      if (result['success'] == true) {
        final data = result['data'];
        final token = data['token'];
        final userData = data['user'];

        await CacheManager.authBox.put('auth_token', token);
        await CacheManager.authBox.put('user_data', userData);

        _user = UserModel.fromJson(userData);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final userData = await _repository.getUser();

      if (userData['success'] == true && userData['data'] != null) {
          _user = UserModel.fromJson(userData['data']);
           await CacheManager.authBox.put('user_data', userData['data']);
          notifyListeners();
      }
    } catch (e) {
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.changePassword(
        currentPassword,
        newPassword,
        confirmPassword
      );

      _isLoading = false;

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengubah password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({String? noTelp, String? alamat, File? foto}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateProfile(
        noTelp: noTelp,
        alamat: alamat,
        foto: foto,
      );

      _isLoading = false;

      if (result['success'] == true) {
        await refreshUser();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal memperbarui profil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    ReminderService().cancelAll();
    notifyListeners();
  }
}
