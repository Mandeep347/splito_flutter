/// Represents a user's net outstanding balance with another counterpart user.
class UserOverallBalance {
  /// The user ID of the counterpart member.
  final String counterpartUserId;

  /// The name of the counterpart member.
  final String counterpartName;

  /// The net amount. Positive if the current user owes the counterpart,
  /// negative if the counterpart owes the current user.
  final double netAmount;

  /// The currency code.
  final String currency;

  /// Creates a new [UserOverallBalance] instance.
  const UserOverallBalance({
    required this.counterpartUserId,
    required this.counterpartName,
    required this.netAmount,
    required this.currency,
  });

  /// Returns true if the current user owes the counterpart.
  bool get youOwe => netAmount > 0;

  /// Returns true if the counterpart owes the current user.
  bool get theyOwe => netAmount < 0;

  /// The absolute value of the net outstanding amount.
  double get absAmount => netAmount.abs();
}
