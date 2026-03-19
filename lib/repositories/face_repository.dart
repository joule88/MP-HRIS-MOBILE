import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_url.dart';
import '../core/cache_manager.dart';
import '../core/error_handler.dart';

class FaceRepository {
  Future<Map<String, dynamic>> enrollFace({
    required File fotoDepan,
    required File fotoKanan,
    required File fotoKiri,
    required File fotoBawah,
  }) async {
    try {
      final token = CacheManager.authBox.get('auth_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiUrl.baseUrl}/face/enroll'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath('foto_depan', fotoDepan.path));
      request.files.add(await http.MultipartFile.fromPath('foto_kanan', fotoKanan.path));
      request.files.add(await http.MultipartFile.fromPath('foto_kiri', fotoKiri.path));
      request.files.add(await http.MultipartFile.fromPath('foto_bawah', fotoBawah.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': true, 'message': 'Pendaftaran wajah berhasil'};
      } else {
        throw Exception('Gagal mendaftarkan wajah: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyFace(File imageFile) async {
    final token = CacheManager.authBox.get('auth_token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/face/verify'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    }

    throw Exception(body['message'] ?? 'Verifikasi gagal');
  }

  Future<Map<String, dynamic>> getFaceStatus() async {
    try {
      final token = CacheManager.authBox.get('auth_token');
      final response = await http.get(
        Uri.parse('${ApiUrl.baseUrl}/face/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      throw Exception('Gagal mengambil status: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
