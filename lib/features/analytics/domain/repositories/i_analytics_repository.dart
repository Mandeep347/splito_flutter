import '../entities/group_analytics.dart';
import '../entities/user_analytics.dart';

/// Abstract contract governing queries for group and user analytics statistics.
abstract interface class IAnalyticsRepository {
  /// Fetches real analytics metrics for a specific group.
  Future<GroupAnalytics> getGroupAnalytics(String groupId);

  /// Fetches cross-group personal analytics metrics for the current user.
  Future<UserAnalytics> getUserAnalytics();
}
