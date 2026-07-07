import 'package:flutter_test/flutter_test.dart';
import 'package:splito_flutter/features/analytics/domain/entities/group_analytics.dart';
import 'package:splito_flutter/features/analytics/domain/services/analytics_computation_service.dart';
import 'package:splito_flutter/features/expenses/domain/entities/expense.dart';
import 'package:splito_flutter/features/expenses/domain/entities/expense_participant.dart';
import 'package:splito_flutter/features/expenses/domain/entities/split_type.dart';
import 'package:splito_flutter/features/settlements/domain/entities/settlement.dart';

final tParticipant1 = ExpenseParticipant(
  userId: 'user-1',
  name: 'Mandeep',
  owedAmount: 1000.0,
);
final tParticipant2 = ExpenseParticipant(
  userId: 'user-2',
  name: 'Rahul',
  owedAmount: 2000.0,
);

final tExpense1 = Expense(
  id: 'exp-1',
  groupId: 'group-1',
  paidByUserId: 'user-1',
  paidByName: 'Mandeep',
  title: 'Dinner',
  totalAmount: 3000.0,
  currency: 'INR',
  splitType: SplitType.equal,
  status: 'ACTIVE',
  createdAt: DateTime(2026, 1, 15),
  participants: [tParticipant1, tParticipant2],
);

final tExpense2 = Expense(
  id: 'exp-2',
  groupId: 'group-1',
  paidByUserId: 'user-2',
  paidByName: 'Rahul',
  title: 'Hotel',
  totalAmount: 6000.0,
  currency: 'INR',
  splitType: SplitType.exact,
  status: 'ACTIVE',
  createdAt: DateTime(2026, 2, 10),
  participants: [tParticipant1, tParticipant2],
);

final tReversedExpense = Expense(
  id: 'exp-3',
  groupId: 'group-1',
  paidByUserId: 'user-1',
  paidByName: 'Mandeep',
  title: 'Cancelled',
  totalAmount: 500.0,
  currency: 'INR',
  splitType: SplitType.equal,
  status: 'REVERSED',
  createdAt: DateTime(2026, 1, 20),
  participants: const [],
);

final tSettlement = Settlement(
  id: 'set-1',
  groupId: 'group-1',
  fromUserId: 'user-2',
  fromUserName: 'Rahul',
  toUserId: 'user-1',
  toUserName: 'Mandeep',
  amount: 1000.0,
  currency: 'INR',
  status: 'COMPLETED',
  createdAt: DateTime(2026, 2, 1),
);

void main() {
  const service = AnalyticsComputationService();

  group('computeGroupAnalytics — totals', () {
    test('totalExpenses sums only ACTIVE expenses', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2, tReversedExpense],
        settlements: const [],
      );
      expect(result.totalExpenses, closeTo(9000.0, 0.01));
    });

    test('totalSettled sums all settlements', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: const [],
        settlements: [tSettlement],
      );
      expect(result.totalSettled, closeTo(1000.0, 0.01));
    });

    test('reversedExpenseCount counts reversed correctly', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2, tReversedExpense],
        settlements: const [],
      );
      expect(result.reversedExpenseCount, 1);
    });

    test('averageExpenseAmount correct for 2 active', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2, tReversedExpense],
        settlements: const [],
      );
      expect(result.averageExpenseAmount, closeTo(4500.0, 0.01));
    });

    test('largestExpense is 6000.0', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2, tReversedExpense],
        settlements: const [],
      );
      expect(result.largestExpense, closeTo(6000.0, 0.01));
    });

    test('smallestExpense is 3000.0', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2, tReversedExpense],
        settlements: const [],
      );
      expect(result.smallestExpense, closeTo(3000.0, 0.01));
    });
  });

  group('computeGroupAnalytics — member contributions', () {
    test('user-1 (Mandeep) totalPaid is 3000.0', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      final c1 = result.memberContributions.firstWhere((c) => c.userId == 'user-1');
      expect(c1.totalPaid, closeTo(3000.0, 0.01));
    });

    test('user-2 (Rahul) totalPaid is 6000.0', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      final c2 = result.memberContributions.firstWhere((c) => c.userId == 'user-2');
      expect(c2.totalPaid, closeTo(6000.0, 0.01));
    });

    test('user-1 totalOwed is correct', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      final c1 = result.memberContributions.firstWhere((c) => c.userId == 'user-1');
      expect(c1.totalOwed, closeTo(2000.0, 0.01));
    });

    test('contributions sorted by totalPaid descending', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      expect(result.memberContributions.first.userId, 'user-2');
    });
  });

  group('computeGroupAnalytics — monthly spending', () {
    test('groups expenses by year-month correctly', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      expect(result.monthlySpending.length, 2);
    });

    test('Jan 2026 total is 3000.0', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      final jan = result.monthlySpending.firstWhere((m) => m.month == 1);
      expect(jan.totalAmount, closeTo(3000.0, 0.01));
    });

    test('sorted ascending by month', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      expect(result.monthlySpending.first.month, 1);
      expect(result.monthlySpending.last.month, 2);
    });
  });

  group('computeGroupAnalytics — date range', () {
    test('dateRangeStart is earliest expense', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      expect(result.dateRangeStart, DateTime(2026, 1, 15));
    });

    test('dateRangeEnd is latest expense', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1, tExpense2],
        settlements: const [],
      );
      expect(result.dateRangeEnd, DateTime(2026, 2, 10));
    });

    test('both null when no active expenses', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tReversedExpense],
        settlements: const [],
      );
      expect(result.dateRangeStart, isNull);
      expect(result.dateRangeEnd, isNull);
    });
  });

  group('computeGroupAnalytics — edge cases', () {
    test('hasData false when no active expenses', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tReversedExpense],
        settlements: const [],
      );
      expect(result.hasData, isFalse);
    });

    test('settlementRate clamped between 0 and 1', () {
      final excessiveSettlement = Settlement(
        id: 'set-excessive',
        groupId: 'group-1',
        fromUserId: 'user-2',
        fromUserName: 'Rahul',
        toUserId: 'user-1',
        toUserName: 'Mandeep',
        amount: 99999.0,
        currency: 'INR',
        status: 'COMPLETED',
        createdAt: DateTime(2026, 2, 1),
      );

      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: [tExpense1],
        settlements: [excessiveSettlement],
      );
      expect(result.settlementRate, lessThanOrEqualTo(1.0));
      expect(result.settlementRate, closeTo(1.0, 0.01));
    });

    test('empty expenses returns zeroed analytics', () {
      final result = service.computeGroupAnalytics(
        groupId: 'group-1',
        currency: 'INR',
        expenses: const [],
        settlements: const [],
      );
      expect(result.totalExpenses, closeTo(0.0, 0.01));
      expect(result.memberContributions, isEmpty);
    });
  });
}
