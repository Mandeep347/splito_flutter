import 'package:flutter/material.dart';

/// Reusable form container wrapper displaying the Splito branding and layout.
class AuthFormWrapper extends StatelessWidget {
  /// The form fields or actions displayed inside the wrapper.
  final Widget child;

  /// Creates a new [AuthFormWrapper] instance.
  const AuthFormWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Splito Logo
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Splito Wordmark
            Text(
              'Splito',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            child,
          ],
        ),
      ),
    );
  }
}
