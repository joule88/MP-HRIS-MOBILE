import 'package:dio/dio.dart';
import '../services/api_client.dart';

class PoinRepository {
  final ApiClient _apiClient;

  PoinRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getExpiringPoints() async {
    try {
      final response = await _apiClient.dio.get('/poin/expiring');

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Gagal mengambil data poin.',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getPointHistory() async {
    try {
      final response = await _apiClient.dio.get('/poin/history');

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Gagal mengambil riwayat poin.',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> tukarPoin({
    required int jumlah,
    required String keterangan,
    required int idPengurangan,
    String? jamMasukCustom,
    String? jamPulangCustom,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'jumlah': jumlah,
        'keterangan': keterangan,
        'id_pengurangan': idPengurangan,
      };

      if (jamMasukCustom != null) {
        data['jam_masuk_custom'] = jamMasukCustom;
      }

      if (jamPulangCustom != null) {
        data['jam_pulang_custom'] = jamPulangCustom;
      }

      final response = await _apiClient.dio.post('/poin/redeem', data: data);

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Poin berhasil ditukar',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Gagal menukar poin',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan server',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> checkSchedule(String tanggal) async {
    try {
      final response = await _apiClient.dio.get('/schedule/check', queryParameters: {
        'tanggal': tanggal,
      });

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Tidak ada jadwal pada tanggal ini',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengecek jadwal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
