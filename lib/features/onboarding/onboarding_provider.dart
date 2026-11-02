import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/storage_providers.dart';

/// Whether the user has finished onboarding on this device.
final onboardingSeenProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(localStorageProvider).onboardingSeen;

  Future<void> complete() async {
    await ref.read(localStorageProvider).setOnboardingSeen();
    state = true;
  }
}
