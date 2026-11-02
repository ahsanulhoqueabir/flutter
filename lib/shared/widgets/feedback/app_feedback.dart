import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/logger.dart';

enum SnackType { info, success, error }

/// Shows a floating message, replacing any message already visible.
void showAppSnack(BuildContext context, String message, {SnackType type = SnackType.info}) {
  final colors = Theme.of(context).colorScheme;
  final (icon, background) = switch (type) {
    SnackType.info => (Icons.info_outline_rounded, colors.inverseSurface),
    SnackType.success => (Icons.check_circle_outline_rounded, AppTheme.success),
    SnackType.error => (Icons.error_outline_rounded, colors.error),
  };
  final foreground = switch (type) {
    SnackType.info => colors.onInverseSurface,
    SnackType.success => Colors.white,
    SnackType.error => colors.onError,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: background,
        content: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
}

/// Turns any thrown error into a user-safe message. Never shows raw exceptions.
String userMessage(Object error) {
  if (error is ApiException) return error.message;
  AppLogger.error('Unexpected error', error);
  return 'Something went wrong. Please try again.';
}

/// Runs a user-triggered [action], showing a snackbar if it fails.
/// Returns true on success. Safe if the screen closes while it runs.
Future<bool> runGuarded(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } on Object catch (error) {
    if (context.mounted) showAppSnack(context, userMessage(error), type: SnackType.error);
    return false;
  }
}

/// Confirmation dialog. Returns true only if the user confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                    minimumSize: const Size(64, 44),
                  )
                : FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
