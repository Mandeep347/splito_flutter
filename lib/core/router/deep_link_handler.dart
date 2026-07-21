import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Singleton handler to listen for incoming deep link URLs (cold and warm start)
/// and navigate the user using GoRouter.
class DeepLinkHandler {
  DeepLinkHandler._();

  /// Shared singleton instance.
  static final DeepLinkHandler instance = DeepLinkHandler._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initializes listening to the deep link stream.
  Future<void> init({required GoRouter router}) async {
    // 1. Handle cold-start links
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, router);
      }
    } catch (_) {}

    // 2. Handle warm-start links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri, router);
      },
      onError: (_) {},
    );
  }

  /// Cancels active stream subscriptions.
  void dispose() {
    _linkSubscription?.cancel();
  }

  void _handleDeepLink(Uri uri, GoRouter router) {
    if (uri.scheme == 'splito' && uri.host == 'app') {
      final path = uri.path;
      final queryParams = uri.queryParameters;

      if (path == '/verify-email' || path == 'verify-email') {
        final token = queryParams['token'] ?? '';
        router.go('/verify-email?token=$token');
      } else if (path == '/reset-password' || path == 'reset-password') {
        final token = queryParams['token'] ?? '';
        router.go('/reset-password?token=$token');
      }
    }
  }
}
