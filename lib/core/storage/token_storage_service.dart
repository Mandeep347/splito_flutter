import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract contract managing persistent JWT token storage operations.
abstract interface class ITokenStorageService {
  /// Writes secure access and refresh tokens to persistent storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Reads the secure access token from storage.
  Future<String?> getAccessToken();

  /// Reads the secure refresh token from storage.
  Future<String?> getRefreshToken();

  /// Deletes access and refresh tokens from secure storage.
  Future<void> clearTokens();

  /// Validates presence of both access and refresh tokens in storage.
  Future<bool> hasTokens();
}

/// Secure storage service implementation using [FlutterSecureStorage].
class TokenStorageService implements ITokenStorageService {
  final FlutterSecureStorage _storage;

  const TokenStorageService(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Changed saveTokens to write both tokens in parallel using Future.wait to prevent sequential awaits
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    // Changed clearTokens to delete both tokens in parallel using Future.wait to prevent sequential awaits
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}

/// Provider exposing [ITokenStorageService].
final tokenStorageServiceProvider = Provider<ITokenStorageService>((ref) {
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  return const TokenStorageService(secureStorage);
});
