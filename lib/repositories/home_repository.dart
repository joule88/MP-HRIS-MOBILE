import '../services/api_client.dart';
import '../../models/user_model.dart';
import '../../models/presensi_model.dart';
import '../../models/announcement_model.dart';
import '../../models/schedule_model.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/dashboard');

      if (response.data['success'] == true) {
        final data = response.data['data'];

        final user = UserModel.fromJson(data['user']);

        final statistik = data['statistik_absensi'];
        final izinCount = statistik?['izin'] ?? 0;
        final alphaCount = statistik?['alpha'] ?? 0;

        PresensiModel? presensiToday;
        if (data['jadwal_hari_ini'] != null) {
          final jadwal = data['jadwal_hari_ini'];
          final presensi = data['presensi_hari_ini'];

          final bool sudahMasuk = presensi != null && presensi['jam_masuk'] != null;
          final bool sudahPulang = presensi != null && presensi['jam_pulang'] != null;

          presensiToday = PresensiModel(
            tanggal: jadwal['hari'] ?? '-',
            shift: jadwal['shift'] ?? '-',
            jamMasuk: sudahMasuk ? presensi['jam_masuk'] : jadwal['jam_masuk'] ?? '-',
            jamPulang: sudahPulang ? presensi['jam_pulang'] : jadwal['jam_pulang'] ?? '-',
            lokasi: '-',
            statusJadwal: jadwal['status_jadwal'],
            isAdjusted: jadwal['is_adjusted'] ?? false,
            adjustmentNote: jadwal['note'],
            sudahAbsenMasuk: sudahMasuk,
            sudahAbsenPulang: sudahPulang,
            statusMasuk: presensi?['keterangan']?.toString(),
            statusPulang: presensi?['keterangan_pulang']?.toString(),
            jadwalJamMasuk: jadwal['jam_masuk']?.toString(),
            jadwalJamPulang: jadwal['jam_pulang']?.toString(),
            kantorNama: jadwal['kantor_nama']?.toString(),
            kantorLat: (jadwal['kantor_lat'] is num) ? (jadwal['kantor_lat'] as num).toDouble() : null,
            kantorLon: (jadwal['kantor_lon'] is num) ? (jadwal['kantor_lon'] as num).toDouble() : null,
            kantorRadius: (jadwal['kantor_radius'] is num) ? (jadwal['kantor_radius'] as num).toDouble() : null,
          );
        }

        final pengumumanList = await getPengumuman();

        return {
          'user': user,
          'poin': data['poin'] ?? 0,
          'presensi_today': presensiToday,
          'pengumuman_list': pengumumanList,
          'sisa_cuti': user.sisaCuti,
          'izin_count': izinCount,
          'alpha_count': alphaCount,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
      }
    } catch (e) {
      print('Error fetching dashboard: $e');
      return {
        'user': null,
        'poin': 0,
        'presensi_today': null,
        'pengumuman_list': <AnnouncementModel>[],
        'sisa_cuti': 0,
        'izin_count': 0,
        'alpha_count': 0,
      };
    }
  }

  Future<List<AnnouncementModel>> getPengumuman() async {
    try {
      final response = await _apiClient.dio.get('/pengumuman');
      if (response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((json) => AnnouncementModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pengumuman: $e');
      return [];
    }
  }

  Future<List<ScheduleModel>> getMonthlySchedule(int month, int year) async {
    try {
      final response = await _apiClient.dio.get(
        '/schedule/monthly',
        queryParameters: {'month': month.toString(), 'year': year.toString()},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];

        print("Data Jadwal Diterima: ${data.length} item");

        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error Repository: $e");
      throw Exception('Gagal memuat jadwal bulanan');
    }
  }
}
