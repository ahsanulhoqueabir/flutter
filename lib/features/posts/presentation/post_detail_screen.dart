import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/async_value_view.dart';
import '../posts_providers.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(postId));

    return Scaffold(
      appBar: AppBar(title: Text('Post #$postId')),
      body: AsyncValueView(
        value: post,
        onRetry: () => ref.invalidate(postProvider(postId)),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(p.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
