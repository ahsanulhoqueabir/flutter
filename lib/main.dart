import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/error/error_handling.dart';
import 'core/network/network_providers.dart';
import 'core/storage/storage_providers.dart';
import 'features/auth/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupErrorHandling();

  // Load anything async that providers need synchronously, then inject it.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      retry: retryPolicy,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionExpiredProvider.overrideWith(
          (ref) =>
              () => ref.read(authProvider.notifier).logout(),
        ),
      ],
      child: const App(),
    ),
  );
}
