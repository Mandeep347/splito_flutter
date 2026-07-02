/// Represents a transaction of settling debt between group members.
class Settlement {
  /// The unique identifier of the settlement.
  final String id;

  /// The unique identifier of the group.
  final String groupId;

  /// The user ID of the debtor (person who paid the settlement).
  final String fromUserId;

  /// The display name of the debtor.
  final String fromUserName;

  /// The user ID of the creditor (person who received the settlement).
  final String toUserId;

  /// The display name of the creditor.
  final String toUserName;

  /// The settlement transaction amount.
  final double amount;

  /// The currency code (e.g. 'INR', 'USD').
  final String currency;

  /// Optional note explaining or tracking the transaction.
  final String? note;

  /// The status of the settlement (e.g. 'COMPLETED', 'PENDING').
  final String status;

  /// The date and time when the settlement was recorded.
  final DateTime createdAt;

  /// Creates a new [Settlement] instance.
  const Settlement({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.currency,
    this.note,
    required this.status,
    required this.createdAt,
  });

  /// Returns true if the settlement is completed.
  bool get isCompleted => status == 'COMPLETED';
}
