import 'package:dio/dio.dart';

import '../utils/logger.dart';

/// Adds `Authorization: Bearer <token>` and reports when that token is rejected.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._readToken, {required this.onSessionExpired});

  final String? Function() _readToken;
  final void Function() onSessionExpired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Compare tokens so a late 401 from an old session can't sign out a new one.
    final sent = err.requestOptions.headers['Authorization'];
    if (err.response?.statusCode == 401 && sent != null && sent == 'Bearer ${_readToken()}') {
      onSessionExpired();
    }
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Logs requests and responses. Enabled by `ENABLE_HTTP_LOGS`.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('-> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.debug('<- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('x ${err.requestOptions.method} ${err.requestOptions.uri}', err.message);
    handler.next(err);
  }
}
