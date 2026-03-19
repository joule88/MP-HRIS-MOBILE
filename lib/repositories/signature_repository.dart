import 'dart:convert';
import 'dart:typed_data';
import '../services/api_client.dart';

class SignatureRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getActiveSignature() async {
    try {
      final response = await _apiClient.dio.get('/signature');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': response.data['message'] ?? 'Gagal'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadSignature(Uint8List pngBytes) async {
    try {
      final base64String = base64Encode(pngBytes);

      final response = await _apiClient.dio.post('/signature', data: {
        'signature_data': 'data:image/png;base64,$base64String',
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': response.data['message'] ?? 'Gagal'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteSignature(String id) async {
    try {
      final response = await _apiClient.dio.delete('/signature/$id');
      return {'success': response.data['success'] == true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
