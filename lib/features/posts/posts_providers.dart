import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/posts_repository.dart';
import 'domain/post.dart';

/// List of posts, shared by any widget that watches it. Fetched once, cached
/// while watched. Call `ref.read(postsProvider.notifier).refresh()` to reload.
final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => ref.watch(postsRepositoryProvider).fetchPosts();

  /// Re-runs [build]; existing data stays visible while reloading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Example mutation: create on the server, then update local state.
  Future<void> add({required String title, required String body}) async {
    final created = await ref.read(postsRepositoryProvider).createPost(title: title, body: body);
    final current = state.value ?? const <Post>[];
    state = AsyncData([created, ...current]);
  }
}

/// A single post by id. Auto-disposed when no screen is watching it.
final postProvider = FutureProvider.autoDispose.family<Post, int>(
  (ref, id) => ref.watch(postsRepositoryProvider).fetchPost(id),
);
