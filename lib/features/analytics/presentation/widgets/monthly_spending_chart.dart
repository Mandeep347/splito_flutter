import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:splito_flutter/features/analytics/domain/entities/monthly_spending.dart';

/// A bar chart widget presenting monthly spending trends.
class MonthlySpendingChart extends StatelessWidget {
  /// The monthly spending data points.
  final List<MonthlySpending> monthlyData;

  /// The currency code.
  final String currency;

  /// The height of the chart container.
  final double height;

  /// Creates a new [MonthlySpendingChart] instance.
  const MonthlySpendingChart({
    super.key,
    required this.monthlyData,
    required this.currency,
    this.height = 200,
  });

  String _currencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currencyCode ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (monthlyData.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No spending data yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxAmount = monthlyData.map((e) => e.totalAmount).reduce(max);
    final maxY = maxAmount == 0.0 ? 10.0 : maxAmount * 1.15;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = monthlyData[groupIndex].monthLabel;
                  final symbol = _currencySymbol(currency);
                  final formatter = NumberFormat('#,##0.00');
                  final formattedAmount = '$symbol${formatter.format(rod.toY)}';
                  return BarTooltipItem(
                    '$formattedAmount\n$month',
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ) ??
                        const TextStyle(),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= monthlyData.length) {
                      return const SizedBox.shrink();
                    }
                    final label = monthlyData[index].monthLabel;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      angle: monthlyData.length > 6 ? 0.5 : 0.0,
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: monthlyData.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.totalAmount,
                    color: theme.colorScheme.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
