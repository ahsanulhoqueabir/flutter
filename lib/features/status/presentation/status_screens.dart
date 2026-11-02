import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/feedback/status_view.dart';

/// Unknown routes and bad deep links.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: StatusView.notFound(onAction: () => context.go(Routes.home))),
    );
  }
}

/// Full-screen offline state for flows that can't work without a connection.
/// Screens usually don't need it: [StatusView.offline] appears inline through
/// `AsyncValueView`, and the banner covers the rest of the app.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  Future<void> _retry(BuildContext context) async {
    final results = await Connectivity().checkConnectivity();
    if (!context.mounted) return;
    if (results.every((r) => r == ConnectivityResult.none)) {
      showAppSnack(context, 'Still offline', type: SnackType.error);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: StatusView.offline(onAction: () => _retry(context))),
    );
  }
}

/// Full-screen maintenance state. Route here when your backend reports downtime.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: StatusView.maintenance(onAction: () => context.go(Routes.home))),
    );
  }
}
