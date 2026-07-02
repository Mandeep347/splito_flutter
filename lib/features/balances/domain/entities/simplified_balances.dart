import 'pairwise_balance.dart';

/// The minimum set of transactions required to settle all debts in a group,
/// computed by the debt simplification algorithm on the backend.
class SimplifiedBalances {
  /// The unique identifier of the group.
  final String groupId;

  /// The currency code.
  final String currency;

  /// The simplified list of pairwise transactions.
  final List<PairwiseBalance> transactions;

  /// Creates a new [SimplifiedBalances] instance.
  const SimplifiedBalances({
    required this.groupId,
    required this.currency,
    required this.transactions,
  });

  /// Returns true if all group balances are fully settled.
  bool get isAllSettled => transactions.isEmpty;
}
