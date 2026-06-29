import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/constants/storage_keys.dart';
import 'package:splito_flutter/core/storage/hive_storage_service.dart';
import '../models/user_model.dart';

/// Abstract contract defining local persistence operations for authenticated user details.
abstract interface class IAuthLocalDatasource {
  /// Caches the current authenticated user's details.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the cached authenticated user's details, if available.
  Future<UserModel?> getCachedUser();

  /// Clears the cached authenticated user details.
  Future<void> clearCachedUser();
}

/// Local datasource implementation using [IHiveStorageService].
class AuthLocalDatasource implements IAuthLocalDatasource {
  final IHiveStorageService _hiveService;
  static const String _cachedUserKey = 'cached_user';

  const AuthLocalDatasource(this._hiveService);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _hiveService.write<Map<String, dynamic>>(
      StorageKeys.settingsBox,
      _cachedUserKey,
      user.toJson(),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final data = _hiveService.read<Map<dynamic, dynamic>>(
      StorageKeys.settingsBox,
      _cachedUserKey,
    );
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> clearCachedUser() async {
    await _hiveService.delete(StorageKeys.settingsBox, _cachedUserKey);
  }
}

/// Provider exposing [IAuthLocalDatasource].
final authLocalDatasourceProvider = Provider<IAuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveStorageServiceProvider);
  return AuthLocalDatasource(hiveService);
});
