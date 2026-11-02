import 'package:flutter/material.dart';

import '../feedback/app_feedback.dart';

/// Asks for confirmation before leaving a screen with unsaved edits.
/// This also covers the Android back gesture.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({super.key, required this.hasChanges, required this.child});

  final bool hasChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final leave = await showConfirmDialog(
          context,
          title: 'Discard changes?',
          message: 'Your unsaved changes will be lost.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
          destructive: true,
        );
        if (leave) navigator.pop();
      },
      child: child,
    );
  }
}
