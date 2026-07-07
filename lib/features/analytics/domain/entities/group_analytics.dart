import 'member_contribution.dart';
import 'monthly_spending.dart';

/// Aggregates all computed statistical properties for a group's transaction history.
class GroupAnalytics {
  /// The unique identifier of the group.
  final String groupId;

  /// The currency code of the aggregated metrics.
  final String currency;

  /// The sum of all active expenses.
  final double totalExpenses;

  /// The sum of all completed settlements.
  final double totalSettled;

  /// The number of active expenses in the group.
  final int activeExpenseCount;

  /// The number of reversed/cancelled expenses in the group.
  final int reversedExpenseCount;

  /// Financial stats per group member, sorted by total paid descending.
  final List<MemberContribution> memberContributions;

  /// Monthly spending metrics, sorted chronologically ascending by year then month.
  final List<MonthlySpending> monthlySpending;

  /// The average transaction amount of active expenses.
  final double averageExpenseAmount;

  /// The maximum transaction amount among active expenses.
  final double largestExpense;

  /// The minimum transaction amount among active expenses.
  final double smallestExpense;

  /// The creation timestamp of the earliest active expense.
  final DateTime? dateRangeStart;

  /// The creation timestamp of the most recent active expense.
  final DateTime? dateRangeEnd;

  /// Creates a new [GroupAnalytics] instance.
  const GroupAnalytics({
    required this.groupId,
    required this.currency,
    required this.totalExpenses,
    required this.totalSettled,
    required this.activeExpenseCount,
    required this.reversedExpenseCount,
    required this.memberContributions,
    required this.monthlySpending,
    required this.averageExpenseAmount,
    required this.largestExpense,
    required this.smallestExpense,
    required this.dateRangeStart,
    required this.dateRangeEnd,
  });

  /// Returns true if the group contains at least one active expense.
  bool get hasData => activeExpenseCount > 0;

  /// The member who paid the largest sum for expenses in the group.
  /// Returns null if there are no member contributions recorded.
  MemberContribution? get topPayer => memberContributions.isEmpty
      ? null
      : memberContributions.reduce((a, b) => a.totalPaid > b.totalPaid ? a : b);

  /// The ratio of settled funds relative to the total active expenses.
  /// Returns a double value clamped between 0.0 and 1.0.
  double get settlementRate => totalExpenses == 0
      ? 0.0
      : (totalSettled / totalExpenses).clamp(0.0, 1.0);
}
