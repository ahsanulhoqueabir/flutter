import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/forms/app_text_field.dart';
import '../auth_providers.dart';
import 'widgets/auth_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await runGuarded(
      context,
      () => ref.read(authProvider.notifier).sendPasswordReset(_email.text),
    );
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      // Same wording whether or not the account exists, so this form can't be
      // used to discover who has an account.
      return AuthLayout(
        title: 'Check your inbox',
        subtitle: 'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
        child: Column(
          children: [
            AppButton(label: 'Back to sign in', onPressed: () => context.go(Routes.login)),
            const Gap(AppSpacing.xs),
            AppButton(
              label: 'Use a different email',
              variant: AppButtonVariant.text,
              onPressed: () => setState(() => _sent = false),
            ),
          ],
        ),
      );
    }

    return AuthLayout(
      title: 'Reset your password',
      subtitle: "Enter your email and we'll send you a reset link.",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppEmailField(controller: _email, textInputAction: TextInputAction.done),
            const Gap(AppSpacing.lg),
            AppButton(label: 'Send reset link', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
