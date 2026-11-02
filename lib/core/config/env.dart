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

  static bool get isProd => name == 'prod';
}
