import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/custom_theme.dart';

/// The root layout widget of the Splito application.
/// Inherits [ConsumerWidget] to watch navigation configurations and styling states.
class SplitoApp extends ConsumerWidget {
  const SplitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // In a fully integrated settings flow, this would watch a ThemeMode provider.
    const selectedThemeMode = ThemeMode.system;

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
