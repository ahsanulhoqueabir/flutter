import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/extensions.dart';
import '../buttons/app_button.dart';

/// Full-area message with an illustration: empty, error, offline, 404...
/// Every "nothing to show" state in the app uses this for a consistent look.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  const StatusView.empty({
    super.key,
    this.title = 'Nothing here yet',
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  }) : isError = false;

  const StatusView.error({
    super.key,
    this.message = 'Please try again in a moment.',
    this.onAction,
    this.actionLabel = 'Try again',
  }) : icon = Icons.error_outline_rounded,
       title = 'Something went wrong',
       isError = true;

  const StatusView.offline({super.key, this.onAction, this.actionLabel = 'Try again'})
    : icon = Icons.wifi_off_rounded,
      title = "You're offline",
      message = 'Check your connection and try again.',
      isError = false;

  const StatusView.notFound({
    super.key,
    this.message = "The page you're looking for doesn't exist or has moved.",
    this.onAction,
    this.actionLabel = 'Go home',
  }) : icon = Icons.explore_off_outlined,
       title = 'Page not found',
       isError = false;

  const StatusView.forbidden({super.key, this.onAction, this.actionLabel})
    : icon = Icons.lock_outline_rounded,
      title = 'No access',
      message = "You don't have permission to view this.",
      isError = false;

  const StatusView.maintenance({super.key, this.onAction, this.actionLabel = 'Try again'})
    : icon = Icons.construction_rounded,
      title = 'Back soon',
      message = "We're doing some maintenance. Thanks for your patience.",
      isError = false;

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = isError ? colors.error : colors.primary;
    final tint = isError ? colors.errorContainer : colors.primaryContainer;

    // Scrollable so it survives short windows, large text and pull-to-refresh.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Breakpoints.formMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Illustration(icon: icon, accent: accent, tint: tint),
                    const Gap(AppSpacing.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall,
                    ),
                    if (message != null) ...[
                      const Gap(AppSpacing.xs),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (onAction != null && actionLabel != null) ...[
                      const Gap(AppSpacing.lg),
                      AppButton(label: actionLabel!, onPressed: onAction, expand: false),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft concentric circles behind an icon; needs no image assets.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon, required this.accent, required this.tint});

  final IconData icon;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 148,
        height: 148,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(shape: BoxShape.circle, color: tint.withValues(alpha: 0.35)),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint, tint.withValues(alpha: 0.55)],
            ),
          ),
          child: Icon(icon, size: 52, color: accent),
        ),
      ),
    );
  }
}
