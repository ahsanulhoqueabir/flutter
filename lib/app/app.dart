import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../features/settings/theme_mode_provider.dart';
import '../shared/widgets/feedback/offline_banner.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: Env.appName,
      debugShowCheckedModeBanner: !Env.isProd,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Honor large text settings, but cap them so layouts stay usable.
        final scaled = media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: 1.4));
        return MediaQuery(
          data: scaled,
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: MediaQuery(
                  // The banner already covers the status bar when it is visible.
                  data: scaled.removePadding(removeTop: !ref.watch(isOnlineProvider)),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
