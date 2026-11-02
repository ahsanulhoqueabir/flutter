/// All route paths in one place. Navigate with `context.push(Routes.x)`,
/// never with hard-coded strings.
abstract final class Routes {
  static const posts = '/';
  static const postDetailPattern = '/posts/:id';
  static const settings = '/settings';

  static String postDetail(int id) => '/posts/$id';
}
