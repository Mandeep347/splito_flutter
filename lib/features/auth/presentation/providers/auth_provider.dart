import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/network/session_invalidator.dart';
import 'package:splito_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:splito_flutter/features/auth/domain/entities/logged_in_user.dart';
import 'package:splito_flutter/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:splito_flutter/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:splito_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:splito_flutter/features/balances/presentation/providers/balance_providers.dart';
import 'package:splito_flutter/features/groups/presentation/providers/group_providers.dart';

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

/// Provider for [VerifyEmailUseCase].
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyEmailUseCase(repository: repository);
});

/// Provider for [ResendVerificationUseCase].
final resendVerificationUseCaseProvider = Provider<ResendVerificationUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResendVerificationUseCase(repository: repository);
});

/// Provider for [ForgotPasswordUseCase].
final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(repository: repository);
});

/// Provider for [ResetPasswordUseCase].
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository: repository);
});

/// Notifier governing the current user session lifecycle state.
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Changed: Moved all ref.watch calls to before the first await to prevent undefined behavior in Riverpod.
    final repository = ref.watch(authRepositoryProvider);
    final getMe = ref.watch(getMeUseCaseProvider);

    // Register the session-expired callback so the network layer
    // can trigger logout without importing auth_provider directly.
    // Uses a post-frame callback to avoid modifying another
    // provider's state during build, which Riverpod disallows.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionExpiredCallbackProvider.notifier).state = () {
        ref.invalidateSelf();
      };
    });

    // Clean up the callback when this notifier is disposed
    // (e.g. on logout when invalidateSelf() is called).
    ref.onDispose(() {
      // Only clear if we are still the registered callback.
      // Use a try-catch because the container may already be
      // disposed during hot restart.
      try {
        ref.read(sessionExpiredCallbackProvider.notifier).state = null;
      } catch (_) {}
    });

    final hasToken = await repository.isAuthenticated();
    if (!hasToken) {
      return const AuthStateUnauthenticated();
    }

    try {
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
      // Tokens are saved. Re-run build() which calls getMe()
      // and resolves to AuthStateAuthenticated or falls back
      // to AuthStateUnauthenticated on its own — no duplicate
      // getMe call here that could falsely report login failure.
      ref.invalidateSelf();
    } on AuthFailure catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
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
      await registerUseCase(
        name: name,
        email: email,
        password: password,
      );

      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Verifies email address using the deep link token.
  Future<void> verifyEmail({required String token}) async {
    state = const AsyncLoading<AuthState>();
    try {
      final verifyEmailUseCase = ref.read(verifyEmailUseCaseProvider);
      await verifyEmailUseCase(token: token);
      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Requests to resend verification email.
  Future<void> resendVerification({required String email}) async {
    state = const AsyncLoading<AuthState>();
    try {
      final resendVerificationUseCase = ref.read(resendVerificationUseCaseProvider);
      await resendVerificationUseCase(email: email);
      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Initiates password recovery process.
  Future<void> forgotPassword({required String email}) async {
    state = const AsyncLoading<AuthState>();
    try {
      final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
      await forgotPasswordUseCase(email: email);
      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Completes password reset with new password.
  Future<void> resetPassword({required String token, required String newPassword}) async {
    state = const AsyncLoading<AuthState>();
    try {
      final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
      await resetPasswordUseCase(token: token, newPassword: newPassword);
      state = const AsyncValue.data(AuthStateUnauthenticated());
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
      _invalidateStaleData();
      state = const AsyncValue.data(AuthStateUnauthenticated());
      ref.invalidateSelf();
    } catch (e) {
      _invalidateStaleData();
      state = const AsyncValue.data(AuthStateUnauthenticated());
      ref.invalidateSelf();
    }
  }

  void _invalidateStaleData() {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(myOverallBalancesProvider);
    ref.invalidate(myGroupsProvider);
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
