import 'dart:math';
import 'package:splito_flutter/features/expenses/domain/entities/expense.dart';
import 'package:splito_flutter/features/settlements/domain/entities/settlement.dart';
import '../entities/group_analytics.dart';
import '../entities/member_contribution.dart';
import '../entities/monthly_spending.dart';

/// Pure computation service calculating mathematical aggregates and statistics
/// client-side for Splito group expenses and settlements.
class AnalyticsComputationService {
  /// Creates a const [AnalyticsComputationService] instance.
  const AnalyticsComputationService();

  /// Computes detailed [GroupAnalytics] based on the provided list of expenses and settlements.
  GroupAnalytics computeGroupAnalytics({
    required String groupId,
    required String currency,
    required List<Expense> expenses,
    required List<Settlement> settlements,
  }) {
    // Step 1 — Filter active vs reversed expenses
    final active = expenses.where((e) => e.isActive).toList();
    final reversed = expenses.where((e) => e.isReversed).toList();

    // Step 2 — Compute totals
    final totalExpenses = active.fold(0.0, (sum, e) => sum + e.totalAmount);
    final totalSettled = settlements.fold(0.0, (sum, t) => sum + t.amount);
    final averageExpenseAmount = active.isEmpty ? 0.0 : totalExpenses / active.length;
    final largestExpense = active.isEmpty ? 0.0 : active.map((e) => e.totalAmount).reduce(max);
    final smallestExpense = active.isEmpty ? 0.0 : active.map((e) => e.totalAmount).reduce(min);

    // Step 3 — Date range
    final sortedActive = List<Expense>.from(active)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final dateRangeStart = sortedActive.isEmpty ? null : sortedActive.first.createdAt;
    final dateRangeEnd = sortedActive.isEmpty ? null : sortedActive.last.createdAt;

    // Step 4 — Member contributions
    final Map<String, _MemberContributionBuilder> contributionMap = {};

    for (final e in active) {
      final payerId = e.paidByUserId;
      final payerName = e.paidByName;
      final builder = contributionMap.putIfAbsent(
        payerId,
        () => _MemberContributionBuilder(userId: payerId, name: payerName),
      );
      builder.totalPaid += e.totalAmount;
      builder.expenseCount += 1;

      for (final p in e.participants) {
        final memberId = p.userId;
        final memberName = p.name;
        final mb = contributionMap.putIfAbsent(
          memberId,
          () => _MemberContributionBuilder(userId: memberId, name: memberName),
        );
        mb.totalOwed += p.owedAmount;
      }
    }

    final memberContributions = contributionMap.values
        .map((b) => MemberContribution(
              userId: b.userId,
              name: b.name,
              totalPaid: b.totalPaid,
              totalOwed: b.totalOwed,
              expenseCount: b.expenseCount,
            ))
        .toList()
      ..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));

    // Step 5 — Monthly spending
    final Map<String, _MonthlySpendingBuilder> monthlyMap = {};
    for (final e in active) {
      final key = '${e.createdAt.year}-${e.createdAt.month}';
      final mb = monthlyMap.putIfAbsent(
        key,
        () => _MonthlySpendingBuilder(
          year: e.createdAt.year,
          month: e.createdAt.month,
        ),
      );
      mb.totalAmount += e.totalAmount;
      mb.expenseCount += 1;
    }

    final monthlySpending = monthlyMap.values
        .map((m) => MonthlySpending(
              year: m.year,
              month: m.month,
              totalAmount: m.totalAmount,
              expenseCount: m.expenseCount,
              currency: currency,
            ))
        .toList()
      ..sort((a, b) {
        final yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;
        return a.month.compareTo(b.month);
      });

    return GroupAnalytics(
      groupId: groupId,
      currency: currency,
      totalExpenses: totalExpenses,
      totalSettled: totalSettled,
      activeExpenseCount: active.length,
      reversedExpenseCount: reversed.length,
      memberContributions: memberContributions,
      monthlySpending: monthlySpending,
      averageExpenseAmount: averageExpenseAmount,
      largestExpense: largestExpense,
      smallestExpense: smallestExpense,
      dateRangeStart: dateRangeStart,
      dateRangeEnd: dateRangeEnd,
    );
  }
}

class _MemberContributionBuilder {
  final String userId;
  final String name;
  double totalPaid = 0.0;
  double totalOwed = 0.0;
  int expenseCount = 0;

  _MemberContributionBuilder({
    required this.userId,
    required this.name,
  });
}

class _MonthlySpendingBuilder {
  final int year;
  final int month;
  double totalAmount = 0.0;
  int expenseCount = 0;

  _MonthlySpendingBuilder({
    required this.year,
    required this.month,
  });
}
