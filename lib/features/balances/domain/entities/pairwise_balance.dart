/// Represents a debt where [fromUserId] owes [toUserId] the [amount] in [currency].
class PairwiseBalance {
  /// The user ID of the debtor (person who owes money).
  final String fromUserId;

  /// The name of the debtor.
  final String fromUserName;

  /// The user ID of the creditor (person who is owed money).
  final String toUserId;

  /// The name of the creditor.
  final String toUserName;

  /// The debt amount.
  final double amount;

  /// The currency code (e.g. 'INR', 'USD').
  final String currency;

  /// Creates a new [PairwiseBalance] instance.
  const PairwiseBalance({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.currency,
  });

  /// Human-readable description of who owes whom.
  String get description => '$fromUserName owes $toUserName';
}
