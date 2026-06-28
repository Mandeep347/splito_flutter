import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract contract for reporting application crashes and severe runtime errors.
/// In production, this integrates with remote monitoring platforms (Sentry, Firebase Crashlytics).
abstract class ICrashReporter {
  /// Reports a caught exception with stack trace and optional context details.
  void report(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  });
}

/// Mock implementation of [ICrashReporter] used for configuration purposes.
class CrashReporter implements ICrashReporter {
  const CrashReporter();

  @override
  void report(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  }) {
    // Placeholder: in release builds, this routes logs to Sentry or Firebase Crashlytics
  }
}

/// Provider for [ICrashReporter] interface.
final crashReporterProvider = Provider<ICrashReporter>((ref) {
  return const CrashReporter();
});
