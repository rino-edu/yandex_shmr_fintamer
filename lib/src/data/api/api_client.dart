import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = _createDio();

  static Dio _createDio() {
    final apiKey = dotenv.env['API_KEY'];
    final baseUrl = dotenv.env['BASE_URL'];

    if (apiKey == null || baseUrl == null) {
      throw Exception(
        'API_KEY or BASE_URL is not set in the .env file. Please ensure it is created and configured.',
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $apiKey';
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}
