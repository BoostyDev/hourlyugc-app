import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state provider (stream of Firebase user)
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Current user data provider (real-time Firestore stream)
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  final user = authState.value;
  if (user == null) {
    return Stream.value(null);
  }

  final authRepo = ref.watch(authRepositoryProvider);
  // Use real-time stream so updates are immediate
  return authRepo.getUserDataStream(user.uid);
});


/// Login provider
final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<AuthResult> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await _authRepository.loginWithGoogle();
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AuthResult(success: false, needsRegistration: false, error: e.toString());
    }
  }

  Future<AuthResult> loginWithApple() async {
    state = const AsyncValue.loading();
    try {
      final result = await _authRepository.loginWithApple();
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AuthResult(success: false, needsRegistration: false, error: e.toString());
    }
  }

  Future<AuthResult> loginWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authRepository.loginWithEmail(email, password);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AuthResult(success: false, needsRegistration: false, error: e.toString());
    }
  }

  Future<AuthResult> registerWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authRepository.registerWithEmail(email, password);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AuthResult(success: false, needsRegistration: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset registration status (for development/testing)
  Future<void> resetRegistration() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resetRegistrationStatus();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear all user data (for development/testing)
  Future<void> clearUserData() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.clearUserData();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

