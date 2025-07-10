/// Base class for all exceptions in the app.
class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

/// Exception for network-related errors (no connection, timeout, etc.).
class NetworkException extends AppException {
  NetworkException({String message = 'Please check your internet connection.'})
    : super(message: message);
}

/// Exception for errors returned by the server API (4xx, 5xx).
class ServerException extends AppException {
  final int? statusCode;

  ServerException({required String message, this.statusCode})
    : super(message: message);

  @override
  String toString() => 'Server Error: $statusCode - $message';
}

/// Exception for errors related to local cache.
class CacheException extends AppException {
  CacheException({String message = 'Failed to handle local data.'})
    : super(message: message);
}
