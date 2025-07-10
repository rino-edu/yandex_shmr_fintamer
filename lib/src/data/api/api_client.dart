import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fintamer/src/data/api/error_interceptor.dart';
import 'package:fintamer/src/data/api/json_parsing_interceptor.dart';

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

    dio.interceptors.addAll([
      RetryInterceptor(
        dio: dio,
        logPrint: print, // Выводит логи в консоль, удобно для отладки
        retries: 3, // Количество повторных попыток
        retryableExtraStatuses: const {
          500, // Internal Server Error
          408, // Request Timeout
          429, // Too Many Requests
        },
        retryDelays: const [
          // Экспоненциальная задержка с небольшим "jitter" (случайностью)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
      ),
      JsonParsingInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $apiKey';
          return handler.next(options);
        },
      ),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
