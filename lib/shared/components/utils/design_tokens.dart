/// Design tokens defining layout constants, scaling, and dimensions for Splito.
/// Prevents hardcoded magic numbers across components.
abstract class AppDesignTokens {
  // Spacing Tokens (Layout offsets, padding, margins)
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;
  static const double spaceXXXL = 48.0;

  // Radius Tokens (Rounded corners)
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 999.0;

  // Animation Duration Tokens
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Icon Size Tokens
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;

  // Button Height Tokens
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;

  // Accessibility Touch Target Constants
  static const double minimumTouchTarget = 48.0;

  // Standard Padding Presets
  static const double screenPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double listSpacing = 8.0;
}
