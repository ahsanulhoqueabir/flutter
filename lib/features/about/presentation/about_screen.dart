import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/brand_mark.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(_packageInfoProvider).value;
    final version = info == null ? '' : 'Version ${info.version} (${info.buildNumber})';

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(child: BrandMark(size: 80)),
          const Gap(AppSpacing.md),
          Text(Env.appName, textAlign: TextAlign.center, style: context.textTheme.headlineSmall),
          const Gap(AppSpacing.xxs),
          Text(
            version,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const Gap(AppSpacing.xl),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.terms),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.privacy),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Open-source licenses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: Env.appName,
                    applicationVersion: info?.version,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder legal text. It MUST be replaced with your own before release.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(title, style: context.textTheme.headlineSmall),
          const Gap(AppSpacing.md),
          const Text('Placeholder. Replace this text with your own legal document before release.'),
        ],
      ),
    );
  }
}
