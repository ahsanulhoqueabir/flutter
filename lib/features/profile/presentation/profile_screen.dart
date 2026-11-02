import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../auth/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final colors = context.colors;
    // Null only for the moment between sign-out and the router's redirect.
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colors.primaryContainer,
              child: Text(
                user.name.initials,
                style: context.textTheme.headlineMedium?.copyWith(color: colors.onPrimaryContainer),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Text(user.name, textAlign: TextAlign.center, style: context.textTheme.headlineSmall),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const Gap(AppSpacing.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(user.phone ?? 'Not set'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Birthday'),
                  subtitle: Text(user.birthDate?.formatted ?? 'Not set'),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          AppButton(
            label: 'Edit profile',
            icon: Icons.edit_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push(Routes.editProfile),
          ),
        ],
      ),
    );
  }
}
