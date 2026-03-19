import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_url.dart';
import '../services/api_client.dart';
import '../models/presensi_model.dart';

class AttendanceRepository {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> checkRadius(double userLat, double userLng) async {
    try {
      final response = await _client.dio.post(
        '${ApiUrl.baseUrl}/presensi/check-radius',
        data: {
          'latitude': userLat,
          'longitude': userLng,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to check radius');
      }
    } catch (e) {
      print('Error checking radius: $e');
      rethrow;
    }
  }

  Future<bool> submitPresensi(
    String type,
    double lat,
    double lng,
    File photoFile, {
    String? keteranganLuarRadius,
    String? keteranganPulang,
  }) async {
    try {
      String fileName = photoFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'status': type,
        'latitude': lat,
        'longitude': lng,
        'foto': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
        if (keteranganLuarRadius != null)
          'keterangan_luar_radius': keteranganLuarRadius,
        if (keteranganPulang != null)
          'keterangan_pulang': keteranganPulang,
      });

      final response = await _client.dio.post(
        '${ApiUrl.baseUrl}/presensi',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 &&
          (response.data['success'] == true || response.data['status'] == 'success')) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengirim absensi');
      }
    } catch (e) {
      if (e is DioException) {
         if (e.response?.statusCode == 401) {
             throw Exception("Wajah tidak dikenali. Silakan coba lagi.");
         }
         if (e.response?.statusCode == 422) {
             throw Exception("Kualitas foto buruk atau data tidak lengkap.");
         }
         throw Exception(e.response?.data['message'] ?? e.message);
      }
      print('Error submitting attendance: $e');
      rethrow;
    }
  }

  Future<List<PresensiHistoryModel>> getHistory() async {
    try {
      final response = await _client.dio.get('${ApiUrl.baseUrl}/presensi/history');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data']['data'] ?? [];
        return data.map((json) => PresensiHistoryModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  Future<bool> resubmitPresensi(int idPresensi, String keterangan) async {
    try {
      final response = await _client.dio.post(
        '${ApiUrl.baseUrl}/presensi/$idPresensi/resubmit',
        data: {'keterangan': keterangan},
      );

      if (response.statusCode == 200 &&
          (response.data['success'] == true || response.data['status'] == 'success')) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengajukan ulang');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.message);
      }
      rethrow;
    }
  }
}
