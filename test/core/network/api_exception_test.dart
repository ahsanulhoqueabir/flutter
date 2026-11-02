import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/core/network/api_exception.dart';

ApiException fromStatus(int code, {Object? data, Map<String, dynamic>? headers}) {
  final options = RequestOptions(path: '/x', headers: headers);
  return ApiException.fromDio(
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: code, data: data),
    ),
  );
}

void main() {
  test('401 without a token is a failed login, with a token an expired session', () {
    expect(fromStatus(401).message, 'Incorrect email or password');
    expect(
      fromStatus(401, headers: {'Authorization': 'Bearer t'}).message,
      'Your session has expired',
    );
  });

  test('maps status codes to types', () {
    expect(fromStatus(403), isA<ForbiddenException>());
    expect(fromStatus(429), isA<TooManyRequestsException>());
    expect(fromStatus(503), isA<MaintenanceException>());
    expect(fromStatus(500), isA<ServerException>());
  });

  test('422 exposes field errors in both common shapes', () {
    final e = fromStatus(
      422,
      data: {
        'message': 'Invalid',
        'errors': {
          'email': ['Taken'],
          'name': 'Too short',
        },
      },
    );
    expect(e, isA<ValidationException>());
    expect((e as ValidationException).fieldErrors, {'email': 'Taken', 'name': 'Too short'});
  });

  test('non-JSON error bodies fall back to a safe message', () {
    expect(fromStatus(500, data: '<html>').message, 'Something went wrong on our side');
  });
}
