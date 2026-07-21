/// Pure domain entity representing a summary of personal spending in a group.
class UserAnalyticsGroup {
  /// Unique identifier of the group.
  final String groupId;

  /// The name of the group.
  final String groupName;

  /// The total spending of all members in this group.
  final double totalSpent;

  /// The amount this user paid in this group.
  final double userPaid;

  /// The user's share of expenses in this group.
  final double userOwed;

  /// Number of expenses paid by this user in this group.
  final int expenseCount;

  /// The currency code of the group.
  final String currency;

  /// Creates a new [UserAnalyticsGroup] instance.
  const UserAnalyticsGroup({
    required this.groupId,
    required this.groupName,
    required this.totalSpent,
    required this.userPaid,
    required this.userOwed,
    required this.expenseCount,
    required this.currency,
  });

  /// The net balance for this user in this group.
  double get netBalance => userPaid - userOwed;
}
