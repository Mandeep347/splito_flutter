import 'monthly_spending.dart';
import 'user_analytics_group.dart';

/// Pure domain entity representing personal spending insights across all groups.
class UserAnalytics {
  /// The user's ID.
  final String userId;

  /// The user's display name.
  final String userName;

  /// Total amount the user has paid as payer.
  final double totalPaidAllGroups;

  /// Total amount the user owes others.
  final double totalOwedToOthers;

  /// Total amount others owe the user.
  final double totalOthersOweUser;

  /// Net balance across all groups (positive = creditor, negative = debtor).
  final double netBalance;

  /// Number of active groups the user belongs to.
  final int totalGroupsCount;

  /// Number of expenses paid by this user across all groups.
  final int totalExpenseCount;

  /// Name of the group with the highest spending.
  final String? mostExpensiveGroupName;

  /// List of group spending breakdowns.
  final List<UserAnalyticsGroup> groups;

  /// User's monthly spending history (based on amount they paid).
  final List<MonthlySpending> monthlySpending;

  /// Creates a new [UserAnalytics] instance.
  const UserAnalytics({
    required this.userId,
    required this.userName,
    required this.totalPaidAllGroups,
    required this.totalOwedToOthers,
    required this.totalOthersOweUser,
    required this.netBalance,
    required this.totalGroupsCount,
    required this.totalExpenseCount,
    this.mostExpensiveGroupName,
    required this.groups,
    required this.monthlySpending,
  });
}
