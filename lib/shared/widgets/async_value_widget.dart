import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';

/// Generic widget to handle [AsyncValue] states automatically.
class AsyncValueWidget<T> extends StatelessWidget {
  /// The [AsyncValue] state to watch.
  final AsyncValue<T> value;

  /// The builder function to build UI when data is available.
  final Widget Function(T data) data;

  /// Optional override for the loading state widget.
  final Widget Function()? loading;

  /// Optional override for the error state widget.
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  /// Optional callback to retry the async operation on failure.
  final VoidCallback? onRetry;

  /// Creates a const [AsyncValueWidget] instance.
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return value.when(
      data: data,
      loading: loading ??
          () => const Center(
                child: CircularProgressIndicator(),
              ),
      error: error ??
          (err, stack) {
            final errorMessage = err is Failure ? err.message : 'An unexpected error occurred.';
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ext.spaceLG),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    SizedBox(height: ext.spaceMD),
                    Text(
                      errorMessage,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (onRetry != null) ...[
                      SizedBox(height: ext.spaceLG),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
    );
  }
}
