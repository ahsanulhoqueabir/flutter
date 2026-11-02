import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/forms/validators.dart';
import 'app_text_field.dart';

/// Password input with a show/hide toggle and optional strength meter.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.showStrength = false,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final Validator? validator;
  final bool showStrength;

  /// Tells password managers to offer to generate and save a password.
  final bool isNewPassword;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: widget.label,
          controller: widget.controller,
          obscureText: _obscured,
          prefixIcon: Icons.lock_outline_rounded,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          validator: widget.validator ?? Validators.required('Enter your password'),
          autofillHints: [
            widget.isNewPassword ? AutofillHints.newPassword : AutofillHints.password,
          ],
          suffix: IconButton(
            tooltip: _obscured ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => setState(() => _obscured = !_obscured),
          ),
        ),
        if (widget.showStrength)
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (_, value, _) => _StrengthMeter(PasswordStrength.of(value.text)),
          ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter(this.strength);

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();
    final color = switch (strength) {
      PasswordStrength.weak => theme.colorScheme.error,
      PasswordStrength.fair => AppTheme.warning,
      _ => AppTheme.success,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: strength.progress),
                duration: const Duration(milliseconds: 200),
                builder: (_, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(strength.label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
