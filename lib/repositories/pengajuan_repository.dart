import 'package:dio/dio.dart';
import 'dart:io';
import '../services/api_client.dart';
import '../../models/pengajuan_model.dart';

class PengajuanRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<PengajuanModel>> getPengajuan({String status = 'pending'}) async {
    try {

      final response = await _apiClient.dio.get(
        '/submission/history',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data']['data'] ?? [];
        return data.map((json) => PengajuanModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pengajuan: $e');
      return [];
    }
  }

  Future<bool> submitPengajuan(String jenis, Map<String, dynamic> data) async {
    try {
      final typesResponse = await _apiClient.dio.get('/submission/types');
      if (typesResponse.data['success'] != true) return false;

      final List types = typesResponse.data['data'];
      final jenisObj = types.firstWhere(
        (t) => t['nama_izin'].toString().toLowerCase() == jenis.toLowerCase(),
        orElse: () => null,
      );

      if (jenisObj == null) throw Exception('Jenis izin tidak ditemukan');
      final int jenisId = jenisObj['id_jenis_izin'];

      FormData formData = FormData.fromMap({
        'id_jenis_izin': jenisId,
        'tanggal_mulai': data['tanggal_mulai'],
        'tanggal_selesai': data['tanggal_selesai'],
        'alasan': data['alasan'],
      });

      if (data['bukti_file'] != null) {
        try {
          final file = File(data['bukti_file']);
          if (await file.exists()) {
            formData.files.add(MapEntry(
              'bukti_file',
              await MultipartFile.fromFile(data['bukti_file']),
            ));
          }
        } catch (e) {
          print('File upload skipped: $e');
        }
      }

      final response = await _apiClient.dio.post('/submission', data: formData);
      return response.data['success'] == true;
    } catch (e) {
      print('Error submitting pengajuan: $e');
      return false;
    }
  }
}
