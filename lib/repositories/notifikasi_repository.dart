import '../services/api_client.dart';
import '../../models/notifikasi_model.dart';

class NotifikasiRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotifikasiModel>> getNotifikasi() async {
    try {
      final response = await _apiClient.dio.get('/notifikasi');
      if (response.data['success'] == true) {
        final List items = response.data['data']['data'] ?? [];
        return items.map((e) => NotifikasiModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifikasi/unread-count');
      if (response.data['success'] == true) {
        return response.data['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.post('/notifikasi/$id/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post('/notifikasi/read-all');
    } catch (_) {}
  }

  Future<void> saveDeviceToken(String token, {String deviceType = 'android'}) async {
    try {
      await _apiClient.dio.post('/device-token', data: {
        'fcm_token': token,
        'device_type': deviceType,
      });
    } catch (_) {}
  }
}
