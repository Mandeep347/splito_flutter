/// Represents a participant in an expense and their share breakdown.
class ExpenseParticipant {
  /// The unique identifier of the user participant.
  final String userId;

  /// The display name of the user participant.
  final String name;

  /// The amount owed by this participant.
  final double owedAmount;

  /// The percentage split of this participant, if applicable.
  final double? percentage;

  /// The number of shares owned by this participant, if applicable.
  final int? shares;

  /// Creates a new [ExpenseParticipant] instance.
  const ExpenseParticipant({
    required this.userId,
    required this.name,
    required this.owedAmount,
    this.percentage,
    this.shares,
  });

  /// Placeholder for future rounding logic. Returns the raw owed amount.
  double get formattedOwedAmount => owedAmount;
}
