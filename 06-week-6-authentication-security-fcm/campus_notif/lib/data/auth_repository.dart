
class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!email.contains('@') || password.length < 6) {
      throw Exception(
        'Email atau kata sandi tidak valid',
      );
    }

    return AuthSession(
      access: 'campus-access-$email',
      refresh: 'campus-refresh-$email',
    );
  }
}
