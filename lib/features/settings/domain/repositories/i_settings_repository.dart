import '../entities/app_settings.dart';

/// Repository interface governing retrieval and updates of local user preferences.
abstract interface class ISettingsRepository {
  /// Fetches current persisted settings, returning defaults if not found.
  Future<AppSettings> getSettings();

  /// Persists full user settings locally.
  Future<void> saveSettings({required AppSettings settings});

  /// Overwrites current local storage configuration with defaults.
  Future<void> resetToDefaults();
}
