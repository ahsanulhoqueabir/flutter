import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/config/env.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/brand_mark.dart';

/// Shown while the session is restored. The router leaves it automatically.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 88),
              const Gap(AppSpacing.lg),
              Text(Env.appName, style: context.textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
