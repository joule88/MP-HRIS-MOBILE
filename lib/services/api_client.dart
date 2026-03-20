import 'package:dio/dio.dart';
import '../core/cache_manager.dart';
import '../core/constants/api_url.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiUrl.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = CacheManager.authBox.get('auth_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('[API Request] ${options.method} ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[API Response] ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response != null) {
          print('[API Error] ${e.response?.statusCode} ${e.requestOptions.path}');
          print('[API Error Data] ${e.response?.data}');
        } else {
          print('[API Network Error] ${e.type}: ${e.message}');
        }
        return handler.next(e);
      },
    ));
  }
}
