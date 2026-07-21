import 'package:intl/intl.dart';
import '../entities/monthly_spending.dart';

/// Fills in any missing months in the last 12 months with zero-spending data points
/// to ensure a continuous x-axis for charts.
List<MonthlySpending> fillMissingMonths(List<MonthlySpending> data) {
  final now = DateTime.now();
  final result = <MonthlySpending>[];
  for (int i = 11; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final existing = data.firstWhere(
      (d) => d.year == month.year && d.month == month.month,
      orElse: () => MonthlySpending(
        year: month.year,
        month: month.month,
        monthLabel: DateFormat('MMM yyyy').format(month),
        totalAmount: 0.0,
        expenseCount: 0,
        currency: 'INR',
      ),
    );
    result.add(existing);
  }
  return result;
}
