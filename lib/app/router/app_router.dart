import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/posts/presentation/post_detail_screen.dart';
import '../../features/posts/presentation/posts_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/status/presentation/status_screens.dart';
import 'app_shell.dart';
import 'routes.dart';

/// Decides where a user may go. Pure, so every path can be unit tested.
String? resolveRedirect({
  required String location,
  required String? from,
  required bool isRestoring,
  required bool isSignedIn,
  required bool onboardingSeen,
}) {
  if (Routes.public.contains(location)) return null;
  if (isRestoring) return location == Routes.splash ? null : Routes.splash;
  if (!onboardingSeen) return location == Routes.onboarding ? null : Routes.onboarding;

  final inEntryFlow =
      Routes.authOnly.contains(location) ||
      location == Routes.splash ||
      location == Routes.onboarding;

  if (!isSignedIn) {
    if (Routes.authOnly.contains(location)) return null;
    if (inEntryFlow) return Routes.login;
    // Remember the deep link so it opens after signing in.
    return Uri(path: Routes.login, queryParameters: {'from': location}).toString();
  }
  // `from` must be an in-app path: a link like ?from=//evil.com is ignored.
  if (inEntryFlow) return from != null && _isInternal(from) ? from : Routes.home;
  return null;
}

bool _isInternal(String path) => path.startsWith('/') && !path.startsWith('//');

/// Router as a provider so guards (`redirect`) can read other providers.
final routerProvider = Provider<GoRouter>((ref) {
  // Re-runs redirect when these change, without rebuilding the router itself.
  final refresh = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(onboardingSeenProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    errorBuilder: (_, _) => const NotFoundScreen(),
    redirect: (_, state) {
      final auth = ref.read(authProvider);
      return resolveRedirect(
        location: state.uri.path,
        from: state.uri.queryParameters['from'],
        isRestoring: auth.isLoading && !auth.hasValue,
        isSignedIn: auth.value != null,
        onboardingSeen: ref.read(onboardingSeenProvider),
      );
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
        path: Routes.terms,
        builder: (_, _) => const LegalScreen(title: 'Terms of Service'),
      ),
      GoRoute(
        path: Routes.privacy,
        builder: (_, _) => const LegalScreen(title: 'Privacy Policy'),
      ),
      GoRoute(path: Routes.offline, builder: (_, _) => const OfflineScreen()),
      GoRoute(path: Routes.maintenance, builder: (_, _) => const MaintenanceScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const PostsScreen()),
              GoRoute(
                path: Routes.postDetailPattern,
                builder: (_, state) {
                  // A malformed deep link such as /posts/abc shows 404 rather than crash.
                  final id = int.tryParse(state.pathParameters['id']!);
                  return id == null ? const NotFoundScreen() : PostDetailScreen(postId: id);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
              GoRoute(path: Routes.editProfile, builder: (_, _) => const EditProfileScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
              GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
              if (!Env.isProd)
                GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
