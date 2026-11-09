import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/auth/is_authenticated.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.read(tokenStoreProvider));
});

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    final repository = ref.read(authRepositoryProvider);
    return IsAuthenticated(repository)();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await Login(repository)(email: email, password: password);
      return true;
    });
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await Logout(repository)();
    state = const AsyncData(false);
  }
}
