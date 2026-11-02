import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../domain/user.dart';

/// An interface here (unlike other features) because auth has two backends.
abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<User> fetchCurrentUser();
  Future<User> updateProfile(User user);
}

/// Real backend. Adjust paths and JSON keys to match your API.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  AuthSession _session(Map<String, dynamic> json) =>
      (token: json['token'] as String, user: User.fromJson(json['user'] as Map<String, dynamic>));

  @override
  Future<AuthSession> login({required String email, required String password}) async => _session(
    await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    ),
  );

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async => _session(
    await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    ),
  );

  @override
  Future<void> sendPasswordReset(String email) =>
      _api.post<void>('/auth/forgot-password', data: {'email': email});

  @override
  Future<User> fetchCurrentUser() async =>
      User.fromJson(await _api.get<Map<String, dynamic>>('/auth/me'));

  @override
  Future<User> updateProfile(User user) async =>
      User.fromJson(await _api.put<Map<String, dynamic>>('/auth/me', data: user.toJson()));
}

/// Demo backend, enabled by `USE_MOCK_AUTH`. Any email and password work, except
/// `wrong@example.com`, which fails so the error path can be seen.
class MockAuthRepository implements AuthRepository {
  static const _delay = Duration(milliseconds: 700);

  User? _user;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    await Future<void>.delayed(_delay);
    if (email == 'wrong@example.com') {
      throw const UnauthorizedException('Incorrect email or password');
    }
    final name = email.split('@').first;
    return (token: 'mock-token', user: _user = User(id: '1', name: name, email: email));
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_delay);
    return (token: 'mock-token', user: _user = User(id: '1', name: name, email: email));
  }

  @override
  Future<void> sendPasswordReset(String email) => Future<void>.delayed(_delay);

  @override
  Future<User> fetchCurrentUser() async {
    await Future<void>.delayed(_delay);
    return _user ?? const User(id: '1', name: 'Demo User', email: 'demo@example.com');
  }

  @override
  Future<User> updateProfile(User user) async {
    await Future<void>.delayed(_delay);
    return _user = user;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => Env.useMockAuth ? MockAuthRepository() : ApiAuthRepository(ref.watch(apiClientProvider)),
);
