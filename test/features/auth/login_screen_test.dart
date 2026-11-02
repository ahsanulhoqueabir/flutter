import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:template/core/network/api_exception.dart';
import 'package:template/features/auth/data/auth_repository.dart';
import 'package:template/features/auth/presentation/login_screen.dart';

import '../../helpers/pump_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() => repo = _MockAuthRepository());

  Future<void> pump(WidgetTester tester) => tester.pumpApp(
    const LoginScreen(),
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );

  testWidgets('empty submit shows validation errors and sends nothing', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyZeroInteractions(repo);
  });

  testWidgets('rejected login shows the server message', (tester) async {
    when(() => repo.login(email: 'a@b.co', password: 'secret'))
        .thenThrow(const UnauthorizedException('Incorrect email or password'));
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'A@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password'), findsOneWidget);
  });
}
