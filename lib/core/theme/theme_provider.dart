import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider governing the application's active [ThemeMode] setting.
/// Defaults to [ThemeMode.system] to match device preferences.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});
