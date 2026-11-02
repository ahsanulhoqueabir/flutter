import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/storage_providers.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'interceptors.dart';

/// Called when the server rejects the token. Overridden in `main.dart` to sign
/// the user out, which keeps `core` from importing feature code.
final sessionExpiredProvider = Provider<void Function()>((ref) => () {});

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

  dio.interceptors.add(
    AuthInterceptor(
      () => ref.read(localStorageProvider).authToken,
      onSessionExpired: () => ref.read(sessionExpiredProvider)(),
    ),
  );
  if (Env.enableHttpLogs) dio.interceptors.add(LoggingInterceptor());

  ref.onDispose(dio.close);
  return dio;
});

/// Repositories depend on this. Never construct [Dio] or [ApiClient] yourself.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));

/// Riverpod retry policy: transient failures only, twice. Riverpod's long default
/// backoff would otherwise keep a spinner on screen when the device is offline.
Duration? retryPolicy(int attempt, Object error) {
  final transient = error is NetworkException || error is RequestTimeoutException;
  return transient && attempt < 2 ? Duration(milliseconds: 500 * (attempt + 1)) : null;
}
