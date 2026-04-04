import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_url.dart';
import '../core/cache_manager.dart';

class FaceRepository {
  Future<Map<String, dynamic>> enrollFace({
    required File videoFile,
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

      request.files.add(await http.MultipartFile.fromPath(
        'video_wajah',
        videoFile.path,
        contentType: MediaType('video', 'mp4'),
      ));

      var streamedResponse = await request.send().timeout(
        const Duration(minutes: 3),
      );
      var response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': body['message'] ?? 'Pendaftaran wajah berhasil',
          'data': body['data'],
        };
      } else {
        throw Exception(body['message'] ?? 'Gagal mendaftarkan wajah: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyFace(File imageFile, {String tipe = 'presensi'}) async {
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
    request.fields['tipe'] = tipe;

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
