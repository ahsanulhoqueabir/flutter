import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/forms/validators.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/feedback/status_view.dart';
import '../../../shared/widgets/forms/app_search_field.dart';
import '../../../shared/widgets/forms/app_text_field.dart';
import '../domain/post.dart';
import '../posts_providers.dart';
import 'widgets/post_tile.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  String _query = '';

  List<Post> _filter(List<Post> posts) {
    if (_query.isEmpty) return posts;
    final q = _query.toLowerCase();
    return posts.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _NewPostSheet(),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppSearchField(
              onChanged: (q) => setState(() => _query = q),
              hint: 'Search posts',
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(postsProvider),
              onRetry: () => ref.invalidate(postsProvider),
              data: (posts) => RefreshIndicator(
                // Old posts stay on screen if the refresh fails; just say why.
                onRefresh: () => runGuarded(context, ref.read(postsProvider.notifier).refresh),
                child: _PostsList(posts: _filter(posts), isSearching: _query.isNotEmpty),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  const _PostsList({required this.posts, required this.isSearching});

  final List<Post> posts;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return isSearching
          ? const StatusView.empty(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: 'Try a different search.',
            )
          : const StatusView.empty(title: 'No posts yet', message: 'Tap + to write the first one.');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 88),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const Gap(AppSpacing.xs),
      itemBuilder: (context, i) =>
          PostTile(post: posts[i], onTap: () => context.push(Routes.postDetail(posts[i].id))),
    );
  }
}

class _NewPostSheet extends ConsumerStatefulWidget {
  const _NewPostSheet();

  @override
  ConsumerState<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends ConsumerState<_NewPostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await runGuarded(
      context,
      () =>
          ref.read(postsProvider.notifier).add(title: _title.text.trim(), body: _body.text.trim()),
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keeps the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Title',
                controller: _title,
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: Validators.compose([
                  Validators.required('Add a title'),
                  Validators.maxLength(120),
                ]),
              ),
              const Gap(AppSpacing.md),
              AppTextField(
                label: 'Body',
                controller: _body,
                minLines: 3,
                maxLines: 6,
                validator: Validators.required('Write something'),
              ),
              const Gap(AppSpacing.lg),
              AppButton(label: 'Publish', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
