import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import '../../domain/entities/activity_feed.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../datasources/activity_local_datasource.dart';
import '../datasources/activity_remote_datasource.dart';

/// Repository implementation delivering group activities.
class ActivityRepositoryImpl implements IActivityRepository {
  /// The remote activities datasource.
  final IActivityRemoteDatasource remoteDatasource;

  /// The local NoSQL caching datasource.
  final IActivityLocalDatasource localDatasource;

  /// Creates a new [ActivityRepositoryImpl] instance.
  const ActivityRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<ActivityFeed> getGroupActivities({
    required String groupId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDatasource.getGroupActivities(groupId: groupId);

      if (page == 1) {
        await localDatasource.cacheActivities(
          groupId: groupId,
          items: models,
        );
      }

      final items = models
          .asMap()
          .entries
          .map((e) => e.value.toEntity(
                groupId: groupId,
                index: e.key,
              ))
          .toList();

      return ActivityFeed(
        groupId: groupId,
        items: items,
        page: 1,
        limit: items.isEmpty ? limit : items.length,
        totalPages: 1,
        totalItems: items.length,
      );
    } on NetworkException {
      if (page == 1) {
        final cached = await localDatasource.getCachedActivities(groupId);
        if (cached != null) {
          final items = cached
              .asMap()
              .entries
              .map((e) => e.value.toEntity(
                    groupId: groupId,
                    index: e.key,
                  ))
              .toList();

          return ActivityFeed(
            groupId: groupId,
            items: items,
            page: 1,
            limit: cached.length,
            totalPages: 1,
            totalItems: cached.length,
          );
        }
      }
      rethrow;
    }
  }
}

/// Provider exposing [IActivityRepository] implementation.
final activityRepositoryProvider = Provider<IActivityRepository>((ref) {
  final remoteDatasource = ref.watch(activityRemoteDatasourceProvider);
  final localDatasource = ref.watch(activityLocalDatasourceProvider);
  return ActivityRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});
