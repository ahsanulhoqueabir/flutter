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
        return _fromResponse(e);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownApiException('Something went wrong. Please try again.');
    }
  }

  static ApiException _fromResponse(DioException e) {
    final data = e.response?.data;
    return switch (e.response?.statusCode ?? 0) {
      // No token sent means a login attempt failed, not an expired session.
      401 when !e.requestOptions.headers.containsKey('Authorization') => UnauthorizedException(
        _extractMessage(data, 'Incorrect email or password'),
      ),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      400 || 422 => ValidationException(
        _extractMessage(data, 'Please check your input'),
        _fieldErrors(data),
      ),
      429 => const TooManyRequestsException(),
      503 => const MaintenanceException(),
      final code => ServerException(
        code,
        _extractMessage(data, 'Something went wrong on our side'),
      ),
    };
  }

  static String _extractMessage(Object? data, String fallback) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return fallback;
  }

  /// Reads `{"errors": {"email": ["Taken"]}}` or `{"errors": {"email": "Taken"}}`.
  static Map<String, String> _fieldErrors(Object? data) {
    final errors = data is Map ? data['errors'] : null;
    if (errors is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in errors.entries)
        if (value is String)
          '$key': value
        else if (value is List && value.isNotEmpty)
          '$key': '${value.first}',
    };
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
  const UnauthorizedException([super.message = 'Your session has expired']);
}

final class ForbiddenException extends ApiException {
  const ForbiddenException() : super('You do not have access to this');
}

final class NotFoundException extends ApiException {
  const NotFoundException() : super('Not found');
}

/// Server rejected the input (400/422). [fieldErrors] maps field name to message.
final class ValidationException extends ApiException {
  const ValidationException(super.message, [this.fieldErrors = const {}]);

  final Map<String, String> fieldErrors;
}

final class TooManyRequestsException extends ApiException {
  const TooManyRequestsException() : super('Too many attempts. Please try again shortly');
}

final class MaintenanceException extends ApiException {
  const MaintenanceException() : super('We are down for maintenance');
}

final class ServerException extends ApiException {
  const ServerException(this.statusCode, String message) : super(message);

  final int statusCode;
}

/// The server replied with a body the app could not understand.
final class BadResponseException extends ApiException {
  const BadResponseException() : super('We received an unexpected response');
}

final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
