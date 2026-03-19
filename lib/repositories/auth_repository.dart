import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw e.response?.data['message'] ?? 'Login gagal';
      }
      throw 'Terjadi kesalahan koneksi';
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _apiClient.dio.get('/user');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw e.response?.data['message'] ?? 'Gagal mengambil data user';
      }
      throw 'Terjadi kesalahan koneksi';
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      final response = await _apiClient.dio.post('/profile/password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw e.response?.data['message'] ?? 'Gagal mengubah password';
      }
      throw 'Terjadi kesalahan koneksi';
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? noTelp,
    String? alamat,
    File? foto,
  }) async {
    try {
      final Map<String, dynamic> formMap = {};

      if (noTelp != null) formMap['no_telp'] = noTelp;
      if (alamat != null) formMap['alamat'] = alamat;
      if (foto != null) {
        formMap['foto'] = await MultipartFile.fromFile(
          foto.path,
          filename: foto.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.dio.post('/profile/update',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw e.response?.data['message'] ?? 'Gagal memperbarui profil';
      }
      throw 'Terjadi kesalahan koneksi';
    }
  }
}
