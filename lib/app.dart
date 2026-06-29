import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/router/app_router.dart';
import 'package:splito_flutter/core/theme/custom_theme.dart';
import 'package:splito_flutter/core/theme/theme_provider.dart';

/// The root layout widget of the Splito application.
/// Inherits [ConsumerWidget] to watch navigation configurations and active theme states.
class SplitoApp extends ConsumerWidget {
  const SplitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // Changed: Watching themeModeProvider dynamically instead of using a hardcoded const ThemeMode local variable
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
