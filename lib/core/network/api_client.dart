import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Thin wrapper around [Dio]. Every HTTP call in the app goes through here.
///
/// Responsibilities: send the request and convert [DioException] into
/// [ApiException]. JSON → model mapping is the repository's job.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? query, CancelToken? cancelToken}) =>
      _send(() => _dio.get<T>(path, queryParameters: query, cancelToken: cancelToken));

  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query}) =>
      _send(() => _dio.post<T>(path, data: data, queryParameters: query));

  Future<T> put<T>(String path, {Object? data}) => _send(() => _dio.put<T>(path, data: data));

  Future<T> patch<T>(String path, {Object? data}) => _send(() => _dio.patch<T>(path, data: data));

  Future<T> delete<T>(String path, {Object? data}) => _send(() => _dio.delete<T>(path, data: data));

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const BadResponseException(); // Body was not the expected JSON shape.
    }
  }
}
