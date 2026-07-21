import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:splito_flutter/features/analytics/domain/entities/monthly_spending.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';

class DashboardLineChart extends StatelessWidget {
  final List<MonthlySpending> monthlyData;
  final String currency;
  final double height;

  const DashboardLineChart({
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
    final ext = theme.extension<AppThemeExtension>()!;

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
    final maxY = maxAmount == 0.0 ? 10.0 : maxAmount * 1.25;

    final spots = monthlyData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalAmount);
    }).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final month = monthlyData[spot.x.toInt()].monthLabel;
                  final symbol = _currencySymbol(currency);
                  final formatter = NumberFormat('#,##0.00');
                  final formattedAmount = '$symbol${formatter.format(spot.y)}';
                  return LineTooltipItem(
                    '$formattedAmount\n$month',
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ) ??
                        const TextStyle(),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == meta.max) return const SizedBox.shrink();
                  final symbol = _currencySymbol(currency);
                  String label = value >= 1000
                      ? '${symbol}${(value / 1000).toStringAsFixed(0)}k'
                      : '${symbol}${value.toStringAsFixed(0)}';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
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
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (monthlyData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.25),
                    theme.colorScheme.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
