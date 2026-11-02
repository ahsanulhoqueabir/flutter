import 'package:dio/dio.dart';

import '../utils/logger.dart';

/// Adds `Authorization: Bearer <token>` when a token is available.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._readToken);

  final String? Function() _readToken;

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
