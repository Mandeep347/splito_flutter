import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/constants/storage_keys.dart';
import 'package:splito_flutter/core/storage/hive_storage_service.dart';
import '../models/group_model.dart';

/// Abstract contract governing NoSQL storage operations for groups.
abstract interface class IGroupLocalDatasource {
  /// Caches a list of groups.
  Future<void> cacheGroups(List<GroupModel> groups);

  /// Retrieves the list of cached groups, or null if none exist.
  Future<List<GroupModel>?> getCachedGroups();

  /// Clears all cached group data.
  Future<void> clearGroupsCache();

  /// Caches details of a single group.
  Future<void> cacheGroup(GroupModel group);

  /// Retrieves details of a cached group by ID, or null.
  Future<GroupModel?> getCachedGroup(String groupId);
}

/// NoSQL storage implementation for groups using [IHiveStorageService].
class GroupLocalDatasource implements IGroupLocalDatasource {
  /// The local storage service dependency.
  final IHiveStorageService storage;

  /// Creates a new [GroupLocalDatasource] instance.
  const GroupLocalDatasource({required this.storage});

  static const String _boxName = StorageKeys.groupsCacheBox;
  static const String _allGroupsKey = 'all_groups';

  @override
  Future<void> cacheGroups(List<GroupModel> groups) async {
    final jsonString = jsonEncode(groups.map((g) => g.toJson()).toList());
    await storage.write<String>(_boxName, _allGroupsKey, jsonString);
  }

  @override
  Future<List<GroupModel>?> getCachedGroups() async {
    final jsonString = storage.read<String>(_boxName, _allGroupsKey);
    if (jsonString == null) return null;
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((item) => GroupModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheGroup(GroupModel group) async {
    final jsonString = jsonEncode(group.toJson());
    await storage.write<String>(_boxName, 'group_${group.id}', jsonString);
  }

  @override
  Future<GroupModel?> getCachedGroup(String groupId) async {
    final jsonString = storage.read<String>(_boxName, 'group_$groupId');
    if (jsonString == null) return null;
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return GroupModel.fromJson(map);
  }

  @override
  Future<void> clearGroupsCache() async {
    await storage.clearBox(_boxName);
  }
}

/// Provider exposing [IGroupLocalDatasource].
final groupLocalDatasourceProvider = Provider<IGroupLocalDatasource>((ref) {
  final storage = ref.watch(hiveStorageServiceProvider);
  return GroupLocalDatasource(storage: storage);
});
