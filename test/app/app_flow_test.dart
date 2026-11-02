import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:template/app/app.dart';
import 'package:template/app/router/app_router.dart';
import 'package:template/core/connectivity/connectivity_provider.dart';
import 'package:template/core/storage/storage_providers.dart';
import 'package:template/features/auth/data/auth_repository.dart';
import 'package:template/features/auth/domain/user.dart';
import 'package:template/features/posts/data/posts_repository.dart';
import 'package:template/features/posts/domain/post.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockPosts extends Mock implements PostsRepository {}

void main() {
  const user = User(id: '1', name: 'Ada Lovelace', email: 'ada@example.com');
  late _MockAuth auth;
  late _MockPosts posts;

  setUp(() {
    auth = _MockAuth();
    posts = _MockPosts();
    when(() => posts.fetchPosts())
        .thenAnswer((_) async => const [Post(id: 1, userId: 1, title: 'Hello', body: 'World')]);
    when(() => auth.login(email: 'ada@example.com', password: 'secret'))
        .thenAnswer((_) async => (token: 't', user: user));
  });

  // Small phone, so any layout overflow fails the test.
  Future<ProviderContainer> boot(WidgetTester tester, Map<String, Object> prefs) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final instance = await SharedPreferences.getInstance();
    final container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(instance),
        isOnlineProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(auth),
        postsRepositoryProvider.overrideWithValue(posts),
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
    await tester.pumpAndSettle();
    return container;
  }

  GoRouter router(ProviderContainer container) => container.read(routerProvider);

  testWidgets('first launch: onboarding, sign in, home, then sign out', (tester) async {
    await boot(tester, {});
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('returning user lands on home and every screen renders', (tester) async {
    final container = await boot(tester, {
      'onboarding_seen': true,
      'auth_token': 't',
      'user': '{"id":"1","name":"Ada Lovelace","email":"ada@example.com"}',
    });
    expect(find.text('Hello'), findsOneWidget);

    for (final (path, expected) in const [
      ('/profile', 'ada@example.com'),
      ('/profile/edit', 'Save changes'),
      ('/settings', 'Appearance'),
      ('/settings/about', 'Privacy Policy'),
      ('/settings/gallery', 'Component gallery'),
      ('/legal/terms', 'Terms of Service'),
      ('/offline', "You're offline"),
      ('/maintenance', 'Back soon'),
      ('/posts/abc', 'Page not found'),
      ('/no/such/page', 'Page not found'),
    ]) {
      router(container).go(path);
      await tester.pumpAndSettle();
      expect(find.text(expected), findsWidgets, reason: path);
    }
  });

  testWidgets('register screen fits a phone and keeps confirm password', (tester) async {
    final container = await boot(tester, {'onboarding_seen': true});
    router(container).go('/register');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(3), 'Abcdefg1');
    await tester.ensureVisible(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Abcdefg1'), findsOneWidget);
    expect(find.text('Please accept to continue'), findsOneWidget);
  });
}
