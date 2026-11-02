import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/posts/presentation/post_detail_screen.dart';
import '../../features/posts/presentation/posts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'routes.dart';

/// Router as a provider so guards (`redirect`) can read other providers, e.g. auth state.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.posts,
    routes: [
      GoRoute(path: Routes.posts, builder: (_, _) => const PostsScreen()),
      GoRoute(
        path: Routes.postDetailPattern,
        builder: (_, state) => PostDetailScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
