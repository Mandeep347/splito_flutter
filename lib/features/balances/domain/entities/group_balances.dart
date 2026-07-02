import 'pairwise_balance.dart';

/// Represents the non-simplified set of pairwise debts in a group.
class GroupBalances {
  /// The unique identifier of the group.
  final String groupId;

  /// The currency code.
  final String currency;

  /// The list of pairwise balances.
  final List<PairwiseBalance> balances;

  /// Creates a new [GroupBalances] instance.
  const GroupBalances({
    required this.groupId,
    required this.currency,
    required this.balances,
  });

  /// Returns true if all group balances are fully settled.
  bool get isAllSettled => balances.isEmpty;

  /// The sum of all outstanding debts in this group.
  double get totalOwed => balances.fold(0.0, (sum, b) => sum + b.amount);
}
