import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:splito_flutter/features/auth/domain/entities/logged_in_user.dart';
import 'package:splito_flutter/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/register_usecase.dart';

/// Sealed class representing the different authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial authentication state on boot before checks run.
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Authentication state when user profile is verified and active.
class AuthStateAuthenticated extends AuthState {
  /// The authenticated user's details.
  final LoggedInUser user;

  const AuthStateAuthenticated({required this.user});
}

/// Authentication state when user is not logged in.
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Provider for [LoginUseCase].
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository: repository);
});

/// Provider for [RegisterUseCase].
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository: repository);
});

/// Provider for [LogoutUseCase].
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository: repository);
});

/// Provider for [GetMeUseCase].
final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository: repository);
});

/// Notifier governing the current user session lifecycle state.
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final hasToken = await repository.isAuthenticated();
    if (!hasToken) {
      return const AuthStateUnauthenticated();
    }

    try {
      final getMe = ref.watch(getMeUseCaseProvider);
      final user = await getMe();
      return AuthStateAuthenticated(user: user);
    } catch (_) {
      // Build errors must resolve to AuthStateUnauthenticated
      return const AuthStateUnauthenticated();
    }
  }

  /// Triggers user login flow and updates session states.
  /// Throws non-auth failures.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthState>();
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      await loginUseCase(email: email, password: password);

      final getMeUseCase = ref.read(getMeUseCaseProvider);
      final user = await getMeUseCase();

      state = AsyncValue.data(AuthStateAuthenticated(user: user));
    } on AuthFailure {
      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Triggers new account registration flow.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthState>();
    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final user = await registerUseCase(
        name: name,
        email: email,
        password: password,
      );

      state = AsyncValue.data(AuthStateAuthenticated(user: user));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Logs out the user session and invalidates state caching.
  Future<void> logout() async {
    state = const AsyncLoading<AuthState>();
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();
      state = const AsyncValue.data(AuthStateUnauthenticated());
      ref.invalidateSelf();
    } catch (e) {
      state = const AsyncValue.data(AuthStateUnauthenticated());
      ref.invalidateSelf();
    }
  }

  /// Attempts to recheck and refresh the current active user details on start.
  Future<void> refreshAndRestore() async {
    state = const AsyncLoading<AuthState>();
    try {
      final getMeUseCase = ref.read(getMeUseCaseProvider);
      final user = await getMeUseCase();
      state = AsyncValue.data(AuthStateAuthenticated(user: user));
    } catch (_) {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AsyncValue.data(AuthStateUnauthenticated());
    }
  }
}

/// Global provider for [AuthNotifier] session state.
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Convenience provider to read true/false authentication status.
final authStateProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull is AuthStateAuthenticated;
});

/// Convenience provider exposing the currently authenticated user details, if available.
final currentUserProvider = Provider<LoggedInUser?>((ref) {
  final state = ref.watch(authNotifierProvider).valueOrNull;
  if (state is AuthStateAuthenticated) {
    return state.user;
  }
  return null;
});

/// Compatibility alias pointing to [authNotifierProvider] to keep network client compilation intact.
final authProvider = authNotifierProvider;
