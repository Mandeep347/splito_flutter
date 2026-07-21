import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:splito_flutter/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:splito_flutter/core/theme/theme_extensions.dart';

class DashboardCategoryPieChart extends StatelessWidget {
  final List<CategoryShare> shares;
  final double height;

  const DashboardCategoryPieChart({
    super.key,
    required this.shares,
    this.height = 200,
  });

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.foodAndDining:
        return const Color(0xFF6366F1); // Indigo
      case ExpenseCategory.travel:
        return const Color(0xFF14B8A6); // Teal
      case ExpenseCategory.shopping:
        return const Color(0xFFF59E0B); // Amber
      case ExpenseCategory.billsAndUtilities:
        return const Color(0xFFEF4444); // Red/Coral
      case ExpenseCategory.other:
        return const Color(0xFF64748B); // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final sections = shares.map((share) {
      final percentageVal = (share.percentage * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: _getCategoryColor(share.category),
        value: share.percentage,
        title: '$percentageVal%',
        radius: 35,
        titleStyle: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          SizedBox(width: ext.spaceMD),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: shares.map((share) {
                final color = _getCategoryColor(share.category);
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ext.spaceXXS),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ext.spaceSM),
                      Expanded(
                        child: Text(
                          share.category.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(share.percentage * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
