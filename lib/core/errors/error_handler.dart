import 'package:splito_flutter/core/errors/failures.dart';

/// Centralized utility class to map domain failures to user-friendly strings.
class AppErrorHandler {
  const AppErrorHandler._();

  /// Maps an error/failure to a user-friendly string message.
  static String toUserMessage(Object? error) {
    if (error == null) {
      return 'An unexpected error occurred.';
    }
    if (error is AuthFailure) {
      return 'Incorrect email or password.';
    }
    if (error is NetworkFailure) {
      return 'No internet connection. Please try again.';
    }
    if (error is ServerFailure) {
      if (error.code == 'USER_ALREADY_EXISTS') {
        return 'An account with this email already exists.';
      }
      if (error.code == 'VALIDATION_ERROR') {
        return error.message;
      }
      return 'Something went wrong. Please try again.';
    }
    if (error is UnknownFailure) {
      return 'An unexpected error occurred.';
    }
    if (error is Failure) {
      return error.message;
    }
    return 'An unexpected error occurred.';
  }
}
