import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fintamer/src/core/error/exceptions.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'DioError: [${err.response?.statusCode}] ${err.type} - ${err.requestOptions.path}',
    );

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: 'The connection has timed out.');

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw NetworkException(message: 'No Internet Connection.');
        }
        throw ServerException(message: 'An unknown error occurred.');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        String serverMessage;
        if (err.response?.data is Map) {
          serverMessage =
              err.response?.data['message'] ?? 'Unknown server error.';
        } else {
          serverMessage = 'Received invalid data from server.';
        }
        throw ServerException(message: serverMessage, statusCode: statusCode);

      case DioExceptionType.cancel:
        // Let the original DioException propagate.
        break;

      case DioExceptionType.badCertificate:
        throw ServerException(message: 'Bad certificate error.');
    }

    return handler.next(err);
  }
}
