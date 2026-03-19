import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../models/surat_izin_model.dart';

class SuratIzinRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<SuratIzinModel>> getSuratIzin() async {
    try {
      final response = await _apiClient.dio.get('/surat-izin');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data']['data'] ?? [];
        return data.map((json) => SuratIzinModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching surat izin: $e');
      return [];
    }
  }

  Future<SuratIzinModel?> getSuratIzinDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('/surat-izin/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return SuratIzinModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching surat detail: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createSuratIzin({
    required String idIzin,
    required String isiSurat,
  }) async {
    try {
      final response = await _apiClient.dio.post('/surat-izin', data: {
        'id_izin': idIzin,
        'isi_surat': isiSurat,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }
      return {'success': false, 'message': response.data['message'] ?? 'Gagal'};
    } on DioException catch (e) {
      String message = 'Gagal membuat surat izin';
      if (e.response?.data != null && e.response!.data is Map) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat surat izin'};
    }
  }
}
