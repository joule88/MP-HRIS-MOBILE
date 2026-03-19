import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/api_config_service.dart';

class ApiUrl {
  static String? _cachedBaseUrl;
  static String? _cachedImageBaseUrl;

  static Future<String> getBaseUrl() async {
    _cachedBaseUrl = await ApiConfigService.getApiUrl();
    return _cachedBaseUrl!;
  }

  static Future<String> getImageBaseUrl() async {
    final baseUrl = await getBaseUrl();
    _cachedImageBaseUrl = ApiConfigService.getStorageUrl(baseUrl);
    return _cachedImageBaseUrl!;
  }

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? _cachedBaseUrl ?? 'http://192.168.1.3:8000/api';
  static String get imageBaseUrl => _cachedImageBaseUrl ?? baseUrl.replaceAll('/api', '/storage/');

  static Future<void> initialize() async {
    await getBaseUrl();
    await getImageBaseUrl();
  }

  static Future<void> reload() async {
    _cachedBaseUrl = null;
    _cachedImageBaseUrl = null;
    await initialize();
  }
}
