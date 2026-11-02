import 'package:flutter_test/flutter_test.dart';
import 'package:template/app/router/app_router.dart';
import 'package:template/app/router/routes.dart';

String? redirect(
  String location, {
  String? from,
  bool restoring = false,
  bool signedIn = false,
  bool onboarded = true,
}) => resolveRedirect(
  location: location,
  from: from,
  isRestoring: restoring,
  isSignedIn: signedIn,
  onboardingSeen: onboarded,
);

void main() {
  test('waits on splash while restoring the session', () {
    expect(redirect(Routes.home, restoring: true), Routes.splash);
    expect(redirect(Routes.splash, restoring: true), isNull);
  });

  test('first launch goes to onboarding', () {
    expect(redirect(Routes.splash, onboarded: false), Routes.onboarding);
    expect(redirect(Routes.onboarding, onboarded: false), isNull);
  });

  test('signed-out users go to login and keep their deep link', () {
    expect(redirect(Routes.splash), Routes.login);
    expect(redirect(Routes.login), isNull);
    expect(redirect('/posts/7'), '/login?from=%2Fposts%2F7');
  });

  test('signed-in users leave the entry flow, honoring safe deep links', () {
    expect(redirect(Routes.login, signedIn: true), Routes.home);
    expect(redirect(Routes.login, signedIn: true, from: '/posts/7'), '/posts/7');
    expect(redirect(Routes.login, signedIn: true, from: '//evil.com'), Routes.home);
    expect(redirect(Routes.login, signedIn: true, from: 'https://evil.com'), Routes.home);
    expect(redirect(Routes.home, signedIn: true), isNull);
  });

  test('public pages are always reachable', () {
    expect(redirect(Routes.terms), isNull);
    expect(redirect(Routes.offline, restoring: true), isNull);
  });
}
