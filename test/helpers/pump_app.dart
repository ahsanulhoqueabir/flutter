import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:template/core/storage/storage_providers.dart';

/// Pumps [child] inside a [ProviderScope] + [MaterialApp] with in-memory prefs.
///
/// Pass extra [overrides] to fake repositories, e.g.
/// `postsRepositoryProvider.overrideWithValue(FakePostsRepository())`.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget child, {List<Override> overrides = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await pumpWidget(
      ProviderScope(
        // Disable Riverpod's automatic retry so error states settle immediately.
        retry: (_, _) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs), ...overrides],
        child: MaterialApp(home: child),
      ),
    );
  }
}
