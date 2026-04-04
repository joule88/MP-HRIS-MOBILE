import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfigService {
  static const String _apiUrlKey = 'api_base_url';
  static const String _selectedPresetKey = 'selected_preset';

  static const Map<String, String> presets = {
    'current_ip': 'http://192.168.110.17:8000/api',
    'hostname': 'http://LAPTOP-I0SUKSKL:8000/api',
    'emulator': 'http://10.0.2.2:8000/api',
    'custom': '',
  };

  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();

    final savedUrl = prefs.getString(_apiUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }

    final selectedPreset = prefs.getString(_selectedPresetKey);
    if (selectedPreset != null && presets.containsKey(selectedPreset)) {
      final presetUrl = presets[selectedPreset];
      if (presetUrl != null && presetUrl.isNotEmpty) {
        return presetUrl;
      }
    }

    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    return presets['hostname']!;
  }

  static Future<void> setCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
    await prefs.setString(_selectedPresetKey, 'custom');
  }

  static Future<void> setPreset(String presetKey) async {
    if (!presets.containsKey(presetKey)) {
      throw Exception('Invalid preset: $presetKey');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPresetKey, presetKey);

    final presetUrl = presets[presetKey];
    if (presetUrl != null && presetUrl.isNotEmpty) {
      await prefs.setString(_apiUrlKey, presetUrl);
    }
  }

  static Future<String> getCurrentPreset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedPresetKey) ?? 'hostname';
  }

  static Future<String?> getSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey);
  }

  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiUrlKey);
    await prefs.remove(_selectedPresetKey);
  }

  static Future<bool> testConnection(String url) async {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String getStorageUrl(String apiUrl) {
    return apiUrl.replaceAll('/api', '/storage/');
  }

  static String getPresetDisplayName(String presetKey) {
    switch (presetKey) {
      case 'current_ip':
        return 'IP Laptop Saat Ini - Recommended';
      case 'hostname':
        return 'Hostname (LAPTOP-I0SUKSKL)';
      case 'emulator':
        return 'Android Emulator (10.0.2.2)';
      case 'custom':
        return 'Custom URL';
      default:
        return presetKey;
    }
  }
}
