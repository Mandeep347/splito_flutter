import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splito_flutter/features/analytics/domain/entities/group_analytics.dart';
import 'package:splito_flutter/shared/widgets/amount_display.dart';

/// Card component displaying group overview metrics inside a responsive grid.
class AnalyticsSummaryCard extends StatelessWidget {
  /// The group analytics computed metrics.
  final GroupAnalytics analytics;

  /// The currency code.
  final String currency;

  /// Creates a new [AnalyticsSummaryCard] instance.
  const AnalyticsSummaryCard({
    super.key,
    required this.analytics,
    required this.currency,
  });

  String _fmt(DateTime date) => DateFormat('d MMM').format(date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (analytics.dateRangeStart != null && analytics.dateRangeEnd != null)
                  Text(
                    '${_fmt(analytics.dateRangeStart!)} – ${_fmt(analytics.dateRangeEnd!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _StatCell(
                  label: 'Total Spent',
                  child: AmountDisplay(
                    amount: analytics.totalExpenses,
                    currency: currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatCell(
                  label: 'Avg Expense',
                  child: AmountDisplay(
                    amount: analytics.averageExpenseAmount,
                    currency: currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatCell(
                  label: 'Expenses',
                  child: Text(
                    '${analytics.activeExpenseCount}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatCell(
                  label: 'Largest',
                  child: AmountDisplay(
                    amount: analytics.largestExpense,
                    currency: currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatCell({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
