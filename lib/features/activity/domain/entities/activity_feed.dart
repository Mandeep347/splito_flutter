import 'activity_item.dart';

/// Represents a paginated feed of activities.
class ActivityFeed {
  /// The ID of the group the feed belongs to.
  final String groupId;

  /// The list of activity items on the current page.
  final List<ActivityItem> items;

  /// The current page number.
  final int page;

  /// The limit of items per page.
  final int limit;

  /// The total number of pages available.
  final int totalPages;

  /// The total number of items across all pages.
  final int totalItems;

  /// Creates a new [ActivityFeed] instance.
  const ActivityFeed({
    required this.groupId,
    required this.items,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
  });

  /// Returns true if there are more pages that can be fetched.
  bool get hasMore => page < totalPages;
}
