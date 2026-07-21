import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/core/router/route_names.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/auth/presentation/widgets/auth_form_wrapper.dart';
import 'package:splito_flutter/shared/widgets/loading_overlay.dart';
import 'package:splito_flutter/shared/widgets/primary_button.dart';

/// Screen notifying the user that verification email was sent,
/// offering verification email resend with a 60s cooldown.
class EmailVerificationPendingPage extends ConsumerStatefulWidget {
  /// The attempted registration email address.
  final String email;

  /// Creates a new [EmailVerificationPendingPage] instance.
  const EmailVerificationPendingPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPendingPage> createState() => _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState extends ConsumerState<EmailVerificationPendingPage> {
  int _cooldownSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resend() async {
    if (_cooldownSeconds > 0) return;
    try {
      await ref.read(authNotifierProvider.notifier).resendVerification(email: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _startCooldown();
      }
    } catch (_) {
      // Error is listened to reactive-style in build
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authAsync = ref.watch(authNotifierProvider);
    final isLoading = authAsync is AsyncLoading;

    ref.listen<AsyncValue<AuthState>>(
      authNotifierProvider,
      (previous, next) {
        if (next is AsyncError) {
          final error = next.error;
          final message = error is Failure
              ? error.message
              : 'Failed to resend verification email. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    return LoadingOverlay(
      isLoading: isLoading,
      child: AuthFormWrapper(
        title: 'Verify your email',
        subtitle: 'We sent a verification link to your email address',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.mark_email_read_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'A verification email has been sent to:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Please click the link inside that email to activate your account. If you do not see it, please check your spam folder.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _cooldownSeconds > 0
                  ? 'Resend Email (${_cooldownSeconds}s)'
                  : 'Resend Email',
              onPressed: _cooldownSeconds > 0 ? null : _resend,
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.goNamed(AppRoutes.loginName),
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
