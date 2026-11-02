import 'package:flutter/material.dart';

/// Stacks an optional label above a form control.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, this.label, this.requiredMark = false, required this.child});

  final String? label;
  final bool requiredMark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (label == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (requiredMark)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Error line for custom [FormField]s, matching the text field error style.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12),
      child: Text(
        message!,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
      ),
    );
  }
}
