/// Storage key constants used across local storage and secure storage.
abstract class StorageKeys {
  // --- Secure Storage Keys ---
  static const String secureAccessToken = 'secure_access_token';
  static const String secureRefreshToken = 'secure_refresh_token';
  static const String secureUserPin = 'secure_user_pin';

  // --- Hive Box Names ---
  static const String settingsBox = 'settings_box';
  static const String groupsCacheBox = 'groups_cache';
  static const String expensesCacheBox = 'expenses_cache';
  static const String friendsCacheBox = 'friends_cache_box';
  static const String offlineQueueBox = 'offline_queue_box';
  static const String activityCacheBox = 'activity_cache';

  // --- Settings Box Keys ---
  static const String themeModeKey = 'settings_theme_mode';
  static const String localeLanguageKey = 'settings_locale_language';
  static const String selectedCurrencyKey = 'settings_selected_currency';
  static const String settingsKey = 'app_settings';
}
