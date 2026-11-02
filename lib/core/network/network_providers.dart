import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/storage_providers.dart';
import 'api_client.dart';
import 'interceptors.dart';

/// The one configured [Dio] instance for the whole app.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(() => ref.read(localStorageProvider).authToken));
  if (Env.enableHttpLogs) dio.interceptors.add(LoggingInterceptor());

  ref.onDispose(dio.close);
  return dio;
});

/// Repositories depend on this. Never construct [Dio] or [ApiClient] yourself.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));
