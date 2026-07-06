import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/router/app_router.dart';
import 'package:splito_flutter/core/theme/custom_theme.dart';
import 'package:splito_flutter/core/theme/theme_provider.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:splito_flutter/features/settings/presentation/providers/settings_providers.dart';

/// The root layout widget of the Splito application.
/// Inherits [ConsumerStatefulWidget] to watch navigation configurations,
/// active theme states, and monitor application lifecycle events.
class SplitoApp extends ConsumerStatefulWidget {
  /// Creates a const [SplitoApp] instance.
  const SplitoApp({super.key});

  @override
  ConsumerState<SplitoApp> createState() => _SplitoAppState();
}

class _SplitoAppState extends ConsumerState<SplitoApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  void _onAppResume() {
    // Refresh unread count when app comes to foreground, if authenticated
    if (ref.read(authStateProvider)) {
      ref.read(unreadCountProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSyncProvider);
    final router = ref.watch(goRouterProvider);
    final selectedThemeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Splito',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: selectedThemeMode,
    );
  }
}
