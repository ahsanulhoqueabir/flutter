/// All route paths in one place. Navigate with `context.push(Routes.x)`,
/// never with hard-coded strings.
abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const home = '/';
  static const postDetailPattern = '/posts/:id';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const about = '/settings/about';
  static const gallery = '/settings/gallery';

  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';
  static const offline = '/offline';
  static const maintenance = '/maintenance';

  static String postDetail(int id) => '/posts/$id';

  /// Only for signed-out users; signed-in users are redirected away.
  static const authOnly = {login, register, forgotPassword};

  /// Reachable whether or not the user is signed in.
  static const public = {terms, privacy, offline, maintenance};
}
