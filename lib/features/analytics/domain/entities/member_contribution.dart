/// Represents a member's financial contribution and share breakdown in a group.
class MemberContribution {
  /// The unique identifier of the member user.
  final String userId;

  /// The display name of the member user.
  final String name;

  /// The total amount this member paid for expenses.
  final double totalPaid;

  /// The total amount this member owes across all expenses.
  final double totalOwed;

  /// The net balance for this member (positive means the group owes them,
  /// negative means they owe the group).
  final double netBalance;

  /// The number of active expenses paid for by this member.
  final int expenseCount;

  /// The percentage of total spending contributed by this member.
  final double percentageOfTotal;

  /// Creates a new [MemberContribution] instance.
  const MemberContribution({
    required this.userId,
    required this.name,
    required this.totalPaid,
    required this.totalOwed,
    required this.netBalance,
    required this.expenseCount,
    required this.percentageOfTotal,
  });

  /// Returns true if this member has paid for at least one expense.
  bool get isTopPayer => totalPaid > 0;

  /// The raw payment share amount. Returns 0.0 if the member paid nothing.
  double get paymentShare => totalPaid == 0 ? 0.0 : totalPaid;
}
