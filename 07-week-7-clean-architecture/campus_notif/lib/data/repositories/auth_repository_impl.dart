import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/token_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }

    final session = AuthSession(
      access: 'campus-access-$email',
      refresh: 'campus-refresh-$email',
    );
    await _tokenStore.save(access: session.access, refresh: session.refresh);
    return session;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _tokenStore.readAccess() != null;
  }

  @override
  Future<void> logout() => _tokenStore.clear();
}
