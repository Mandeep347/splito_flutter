/// Represents a single activity item in the activity feed.
class ActivityItem {
  /// The unique identifier of the activity item.
  final String id;

  /// The ID of the group where this activity occurred.
  final String groupId;

  /// The type of activity (e.g. 'EXPENSE_ADDED', 'SETTLEMENT_CREATED').
  final String type;

  /// The display name of the user who performed the action.
  final String actorName;

  /// The unique user ID of the actor.
  final String actorUserId;

  /// The human-readable description of what happened.
  final String description;

  /// Optional identifier of the related entity (e.g. expense ID or settlement ID).
  final String? entityId;

  /// Optional type of the related entity (e.g. 'EXPENSE' or 'SETTLEMENT').
  final String? entityType;

  /// The date and time when the activity occurred.
  final DateTime createdAt;

  /// Creates a new [ActivityItem] instance.
  const ActivityItem({
    required this.id,
    required this.groupId,
    required this.type,
    required this.actorName,
    required this.actorUserId,
    required this.description,
    this.entityId,
    this.entityType,
    required this.createdAt,
  });

  /// Returns true if this activity represents an expense event.
  bool get isExpenseActivity => type.startsWith('EXPENSE_');

  /// Returns true if this activity represents a settlement event.
  bool get isSettlementActivity => type.startsWith('SETTLEMENT_');

  /// Returns true if this activity represents a member changes event.
  bool get isMemberActivity => type.startsWith('MEMBER_');

  /// The icon key derived from the activity type, used by UI to select icons.
  String get iconKey => type;
}
