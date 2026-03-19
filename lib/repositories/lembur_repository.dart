import '../services/api_client.dart';

class LemburRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> submitLembur({
    required String tanggalLembur,
    required String jamMulai,
    required String jamSelesai,
    String? keterangan,
    int? idKompensasi,
  }) async {
    try {
      final response = await _apiClient.dio.post('/lembur', data: {
        'tanggal_lembur': tanggalLembur,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'keterangan': keterangan,
        'id_kompensasi': idKompensasi,
      });

      return {
        'success': true,
        'message': response.data['message'] ?? 'Lembur berhasil diajukan',
        'data': response.data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengajukan lembur: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getLemburHistory() async {
    try {
      final response = await _apiClient.dio.get('/lembur/history');

      return {
        'success': true,
        'data': response.data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat riwayat lembur',
      };
    }
  }
}
