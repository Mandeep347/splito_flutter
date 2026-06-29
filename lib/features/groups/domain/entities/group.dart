import 'group_member.dart';

/// Represents a Splito group.
class Group {
  /// The unique identifier of the group.
  final String id;

  /// The name of the group.
  final String name;

  /// The default currency symbol/code for the group.
  final String defaultCurrency;

  /// The current status of the group (e.g. 'ACTIVE', 'ARCHIVED').
  final String status;

  /// The user ID of the creator of the group.
  final String createdBy;

  /// The date and time when the group was created.
  final DateTime createdAt;

  /// The number of members in the group.
  final int membersCount;

  /// The list of members in the group.
  final List<GroupMember> members;

  /// Creates a new [Group] instance.
  const Group({
    required this.id,
    required this.name,
    required this.defaultCurrency,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.membersCount,
    this.members = const [],
  });

  /// Check if the group is currently active.
  bool get isActive => status == 'ACTIVE';

  /// Check if the group is archived.
  bool get isArchived => status == 'ARCHIVED';
}
