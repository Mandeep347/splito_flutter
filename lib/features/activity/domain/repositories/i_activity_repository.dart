import '../entities/activity_feed.dart';

/// Abstract contract governing activity operations.
abstract interface class IActivityRepository {
  /// Fetches a paginated feed of activities for a specific group.
  Future<ActivityFeed> getGroupActivities({
    required String groupId,
    int page = 1,
    int limit = 20,
  });
}
