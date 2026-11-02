import 'dart:async';

import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

/// The app's button. If [onPressed] returns a Future, it shows a spinner and
/// ignores taps until it completes, which prevents double submissions.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final FutureOr<void> Function()? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// Fill the available width.
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _running = false;

  bool get _busy => _running || widget.isLoading;

  Future<void> _handlePress() async {
    final result = widget.onPressed!();
    if (result is! Future) return;
    setState(() => _running = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onPressed = widget.onPressed == null || _busy ? null : _handlePress;

    final child = _busy
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              semanticsLabel: 'Loading',
              color: colors.onSurfaceVariant,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[Icon(widget.icon, size: 20), const SizedBox(width: 8)],
              Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final button = switch (widget.variant) {
      AppButtonVariant.primary => FilledButton(onPressed: onPressed, child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: onPressed, child: child),
      AppButtonVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colors.error,
          foregroundColor: colors.onError,
        ),
        onPressed: onPressed,
        child: child,
      ),
    };

    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
