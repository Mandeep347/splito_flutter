/// Represents the total spending data point for a specific month.
class MonthlySpending {
  /// The calendar year.
  final int year;

  /// The calendar month (1-indexed, e.g. 1 for January).
  final int month;

  /// User-friendly month label.
  final String monthLabel;

  /// The total transaction spending amount in this month.
  final double totalAmount;

  /// The number of expenses created in this month.
  final int expenseCount;

  /// The currency code of the spending amounts.
  final String currency;

  /// Creates a new [MonthlySpending] instance.
  const MonthlySpending({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.totalAmount,
    required this.expenseCount,
    this.currency = 'INR',
  });

  /// Friendly label representing the year-month span, e.g. 'Jan 2026'.
  String get periodLabel => '$monthLabel $year';
}
