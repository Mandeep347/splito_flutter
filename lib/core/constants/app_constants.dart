import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application wide constants loaded from environment settings.
class AppConstants {
  const AppConstants._();

  /// The base URL of the FastAPI backend.
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://127.0.0.1:8000/api/v1');

  /// Connection timeout in milliseconds.
  static int get connectTimeoutMs => int.parse(dotenv.get('CONNECT_TIMEOUT_MS', fallback: '15000'));

  /// Receive timeout in milliseconds.
  static int get receiveTimeoutMs => int.parse(dotenv.get('RECEIVE_TIMEOUT_MS', fallback: '15000'));
}

/// Constants defining backend REST API endpoint paths.
class ApiEndpoints {
  const ApiEndpoints._();

  /// Endpoint to request login and acquire JWT tokens.
  static const String login = '/auth/login';

  /// Endpoint to register a new user profile.
  static const String register = '/auth/register';

  /// Endpoint to refresh a expired authentication access token.
  static const String refresh = '/auth/refresh';

  /// Endpoint to get or update the current user profile.
  static const String usersMe = '/users/me';
}
