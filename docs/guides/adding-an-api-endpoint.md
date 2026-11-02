# Adding an API endpoint

Use this when a feature already exists and you need one more request.

## Reading data

1. Add a method to the feature's repository:
   ```dart
   Future<List<Comment>> fetchComments(int postId) async {
     final data = await _api.get<List<dynamic>>('/posts/$postId/comments');
     return data.cast<Map<String, dynamic>>().map(Comment.fromJson).toList();
   }
   ```
2. Expose it with a provider. Because it takes an argument, use `family`:
   ```dart
   final commentsProvider = FutureProvider.autoDispose.family<List<Comment>, int>(
     (ref, postId) => ref.watch(postsRepositoryProvider).fetchComments(postId),
   );
   ```
3. Use it in a widget: `ref.watch(commentsProvider(post.id))`.

## Changing data (POST / PUT / PATCH / DELETE)

1. Add the repository method:
   ```dart
   Future<void> deletePost(int id) => _api.delete<void>('/posts/$id');
   ```
2. Add an action to the notifier that owns the data, and update its state:
   ```dart
   Future<void> remove(int id) async {
     await ref.read(postsRepositoryProvider).deletePost(id);
     state = AsyncData([...?state.value?.where((p) => p.id != id)]);
   }
   ```
3. Call it from the UI and show errors:
   ```dart
   onPressed: () async {
     try {
       await ref.read(postsProvider.notifier).remove(post.id);
     } on ApiException catch (e) {
       if (!context.mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
     }
   },
   ```

## Query parameters

```dart
_api.get<List<dynamic>>('/posts', query: {'userId': userId, '_limit': 20});
```

## Checklist

- [ ] Endpoint lives in the repository, not in a widget or provider
- [ ] Returns a model, not raw JSON
- [ ] Test added
- [ ] `dart run scripts/check.dart` passes
