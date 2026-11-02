import 'package:dio/dio.dart';

/// The single error type that leaves the network layer.
///
/// Repositories and UI only ever deal with [ApiException], never [DioException].
sealed class ApiException implements Exception {
  const ApiException(this.message);

  /// Human-readable message, safe to show in the UI.
  final String message;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const RequestTimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const CancelledException();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 401) return const UnauthorizedException();
        if (code == 404) return const NotFoundException();
        return ServerException(code, _extractMessage(e.response?.data));
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownApiException(e.message ?? 'Unexpected error');
    }
  }

  static String _extractMessage(Object? data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return 'Server error';
  }

  @override
  String toString() => message;
}

final class NetworkException extends ApiException {
  const NetworkException() : super('No internet connection');
}

final class RequestTimeoutException extends ApiException {
  const RequestTimeoutException() : super('The request timed out');
}

final class CancelledException extends ApiException {
  const CancelledException() : super('The request was cancelled');
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Your session has expired');
}

final class NotFoundException extends ApiException {
  const NotFoundException() : super('Not found');
}

final class ServerException extends ApiException {
  const ServerException(this.statusCode, String message) : super(message);

  final int statusCode;
}

final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
