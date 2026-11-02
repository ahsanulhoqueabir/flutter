import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:template/core/network/api_client.dart';
import 'package:template/core/network/api_exception.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ApiClient client;

  setUp(() {
    dio = _MockDio();
    client = ApiClient(dio);
  });

  test('returns response data on success', () async {
    when(() => dio.get<Map<String, dynamic>>('/x', queryParameters: null, cancelToken: null))
        .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/x'),
            data: {'ok': true},
          ),
        );

    expect(await client.get<Map<String, dynamic>>('/x'), {'ok': true});
  });

  test('maps 404 DioException to NotFoundException', () async {
    final options = RequestOptions(path: '/x');
    when(() => dio.get<Map<String, dynamic>>('/x', queryParameters: null, cancelToken: null))
        .thenThrow(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );

    expect(client.get<Map<String, dynamic>>('/x'), throwsA(isA<NotFoundException>()));
  });

  test('maps connection error to NetworkException', () async {
    when(() => dio.get<Map<String, dynamic>>('/x', queryParameters: null, cancelToken: null))
        .thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionError,
          ),
        );

    expect(client.get<Map<String, dynamic>>('/x'), throwsA(isA<NetworkException>()));
  });
}
