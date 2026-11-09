
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/token_store.dart';

// ==========================================
// TOKEN STORE PROVIDER
// ==========================================

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// ==========================================
// AUTH REPOSITORY PROVIDER
// ==========================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ==========================================
// AUTH STATE PROVIDER
// ==========================================

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.read(
      tokenStoreProvider,
    ).readAccess();

    return token != null;
  }

  // ========================================
  // LOGIN
  // ========================================

  Future<void> login(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
          );

      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
          );

      return true;
    });
  }

  // ========================================
  // LOGOUT
  // ========================================

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();

    state = const AsyncData(false);
  }
}
