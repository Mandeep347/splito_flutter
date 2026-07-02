import 'package:flutter/material.dart';

/// Extension on [ColorScheme] to provide semantic financial colours.
extension FinancialColors on ColorScheme {
  /// Color indicating that the current user owes money (red).
  Color get oweColor => Colors.red.shade600;

  /// Color indicating that someone owes the current user money (green).
  Color get owedColor => Colors.green.shade600;
}
