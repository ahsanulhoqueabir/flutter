import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:template/core/network/api_exception.dart';
import 'package:template/features/posts/data/posts_repository.dart';
import 'package:template/features/posts/domain/post.dart';
import 'package:template/features/posts/presentation/posts_screen.dart';

import '../../helpers/pump_app.dart';

class _MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late _MockPostsRepository repo;

  setUp(() => repo = _MockPostsRepository());

  testWidgets('shows posts from the repository', (tester) async {
    when(() => repo.fetchPosts())
        .thenAnswer((_) async => const [Post(id: 1, userId: 1, title: 'Hello', body: 'World')]);

    await tester.pumpApp(
      const PostsScreen(),
      overrides: [postsRepositoryProvider.overrideWithValue(repo)],
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('shows error view with retry on failure', (tester) async {
    when(() => repo.fetchPosts()).thenThrow(const NetworkException());

    await tester.pumpApp(
      const PostsScreen(),
      overrides: [postsRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.pumpAndSettle();

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
