import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../domain/post.dart';

/// All HTTP access for the posts feature. Endpoints are listed here and nowhere else.
class PostsRepository {
  PostsRepository(this._api);

  final ApiClient _api;

  Future<List<Post>> fetchPosts() async {
    final data = await _api.get<List<dynamic>>('/posts');
    return data.cast<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<Post> fetchPost(int id) async {
    final data = await _api.get<Map<String, dynamic>>('/posts/$id');
    return Post.fromJson(data);
  }

  Future<Post> createPost({required String title, required String body}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/posts',
      data: {'title': title, 'body': body, 'userId': 1},
    );
    return Post.fromJson(data);
  }
}

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(ref.watch(apiClientProvider)),
);
