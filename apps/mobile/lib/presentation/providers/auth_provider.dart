import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'base_providers.dart';
import '../../core/network/background_service_handler.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String deviceId;

  AuthState({
    required this.status, 
    this.error, 
    this.deviceId = 'test-device-id',
  });
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState(status: AuthStatus.unknown);

  Future<void> checkAuth() async {
    print('AuthNotifier: checkAuth() starting');
    final repository = ref.read(authRepositoryProvider);
    final loggedIn = await repository.isLoggedIn();
    print('AuthNotifier: isLoggedIn = $loggedIn');
    state = AuthState(status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated);
    if (loggedIn) {
      BackgroundServiceHandler.start();
    }
    print('AuthNotifier: Status set to ${state.status}');
  }

  Future<void> login(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated);
      BackgroundServiceHandler.start();
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    BackgroundServiceHandler.stop();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
