import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/brand_mark.dart';

/// Shared frame for auth screens: soft gradient, brand mark, heading, and a
/// scrollable centered column so the keyboard never hides the form.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [colors.primaryContainer.withValues(alpha: 0.6), colors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const Gap(AppSpacing.lg),
                    Text(title, style: context.textTheme.headlineMedium),
                    const Gap(AppSpacing.xs),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const Gap(AppSpacing.xl),
                    child,
                    if (footer != null) ...[const Gap(AppSpacing.lg), Center(child: footer)],
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

/// "Question? Action" line at the bottom of auth screens.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(question, style: TextStyle(color: context.colors.onSurfaceVariant)),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}
