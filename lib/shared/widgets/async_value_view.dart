import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import 'feedback/app_feedback.dart';
import 'feedback/status_view.dart';
import 'loading_view.dart';

/// Renders an [AsyncValue] with consistent loading and error UI, choosing the
/// right view for each failure (offline, maintenance, not found...).
///
/// If a reload fails while old data exists, the old data stays on screen.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({super.key, required this.value, required this.data, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipError: value.hasValue,
      data: data,
      loading: () => const LoadingView(),
      error: (error, _) => switch (error) {
        NetworkException() || RequestTimeoutException() => StatusView.offline(onAction: onRetry),
        MaintenanceException() => StatusView.maintenance(onAction: onRetry),
        ForbiddenException() => const StatusView.forbidden(),
        NotFoundException() => const StatusView.notFound(
          message: 'This item may have been removed.',
        ),
        _ => StatusView.error(message: userMessage(error), onAction: onRetry),
      },
    );
  }
}
