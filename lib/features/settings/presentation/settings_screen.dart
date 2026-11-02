import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../auth/auth_providers.dart';
import '../theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (confirmed) await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    const chevron = Icon(Icons.chevron_right_rounded);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _Section('Appearance'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          const _Section('General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About'),
                  trailing: chevron,
                  onTap: () => context.push(Routes.about),
                ),
                if (!Env.isProd) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.widgets_outlined),
                    title: const Text('Component gallery'),
                    subtitle: const Text('Environment: ${Env.name}'),
                    trailing: chevron,
                    onTap: () => context.push(Routes.gallery),
                  ),
                ],
              ],
            ),
          ),
          const _Section('Account'),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: context.colors.error),
              title: Text('Sign out', style: TextStyle(color: context.colors.error)),
              onTap: () => _signOut(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(color: context.colors.primary),
      ),
    );
  }
}
