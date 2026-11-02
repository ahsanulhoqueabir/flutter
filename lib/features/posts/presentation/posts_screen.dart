import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../posts_providers.dart';
import 'widgets/post_tile.dart';

class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: AsyncValueView(
        value: posts,
        onRetry: () => ref.invalidate(postsProvider),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.read(postsProvider.notifier).refresh(),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                PostTile(post: items[i], onTap: () => context.push(Routes.postDetail(items[i].id))),
          ),
        ),
      ),
    );
  }
}
