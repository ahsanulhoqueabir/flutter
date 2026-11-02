import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/utils/logger.dart';
import 'data/auth_repository.dart';
import 'domain/user.dart';

/// The signed-in user, or `null` when signed out. The router listens to this
/// to redirect between auth and app screens.
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final storage = ref.watch(localStorageProvider);
    if (storage.authToken == null) return null;

    // A cached user lets the app open instantly, including offline.
    final cached = _parseCachedUser(storage.user);
    if (cached != null) return cached;

    try {
      final user = await ref.read(authRepositoryProvider).fetchCurrentUser();
      await storage.setUser(user.toJson());
      return user;
    } on UnauthorizedException {
      await storage.clearSession();
      return null;
    } on ApiException catch (e) {
      // Token may still be valid: keep it, but ask the user to sign in.
      AppLogger.error('Could not restore session', e);
      return null;
    }
  }

  User? _parseCachedUser(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return User.fromJson(json);
    } on TypeError {
      return null; // Cache written by an older app version.
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: _normalizeEmail(email), password: password);
    await _startSession(session);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(name: name.trim(), email: _normalizeEmail(email), password: password);
    await _startSession(session);
  }

  Future<void> sendPasswordReset(String email) =>
      ref.read(authRepositoryProvider).sendPasswordReset(_normalizeEmail(email));

  Future<void> updateProfile(User user) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(user);
    await ref.read(localStorageProvider).setUser(updated.toJson());
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    await ref.read(localStorageProvider).clearSession();
    state = const AsyncData(null);
  }

  Future<void> _startSession(AuthSession session) async {
    final storage = ref.read(localStorageProvider);
    await storage.setAuthToken(session.token);
    await storage.setUser(session.user.toJson());
    state = AsyncData(session.user);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}

/// Current user id. Providers holding per-user data watch this, so their cache
/// resets when the user changes and one account never sees another's data.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authProvider.select((auth) => auth.value?.id)),
);
