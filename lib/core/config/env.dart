/// Compile-time environment configuration.
///
/// Values come from `--dart-define-from-file=config/<env>.json`.
/// Never call `String.fromEnvironment` anywhere else in the app.
abstract final class Env {
  static const String name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'Template');
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );
  static const bool enableHttpLogs = bool.fromEnvironment('ENABLE_HTTP_LOGS');

  /// Use the in-memory auth backend instead of real `/auth/*` endpoints.
  /// Defaults to false so a misconfigured build can never accept fake logins.
  static const bool useMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');

  static bool get isProd => name == 'prod';
}
