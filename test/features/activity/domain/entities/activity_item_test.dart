import 'package:flutter_test/flutter_test.dart';
import 'package:splito_flutter/features/activity/domain/entities/activity_item.dart';

void main() {
  group('ActivityItem', () {
    test('isExpenseActivity true for EXPENSE_ prefix', () {
      final activity = ActivityItem(
        id: '1',
        groupId: 'g1',
        type: 'EXPENSE_CREATED',
        actorName: 'Mandeep',
        actorUserId: '',
        description: 'Mandeep added an expense',
        entityId: null,
        entityType: 'expense',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(activity.isExpenseActivity, isTrue);
    });

    test('isSettlementActivity true for SETTLEMENT_ prefix', () {
      final activity = ActivityItem(
        id: '2',
        groupId: 'g1',
        type: 'SETTLEMENT_RECORDED',
        actorName: 'Mandeep',
        actorUserId: '',
        description: 'Mandeep recorded a payment',
        entityId: null,
        entityType: 'settlement',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(activity.isSettlementActivity, isTrue);
    });

    test('isMemberActivity true for MEMBER_ prefix', () {
      final activity = ActivityItem(
        id: '3',
        groupId: 'g1',
        type: 'MEMBER_ADDED',
        actorName: 'Mandeep',
        actorUserId: '',
        description: 'Mandeep joined the group',
        entityId: null,
        entityType: 'member',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(activity.isMemberActivity, isTrue);
    });

    test('isExpenseActivity false for SETTLEMENT_ type', () {
      final activity = ActivityItem(
        id: '4',
        groupId: 'g1',
        type: 'SETTLEMENT_RECORDED',
        actorName: 'Mandeep',
        actorUserId: '',
        description: 'Mandeep recorded a payment',
        entityId: null,
        entityType: 'settlement',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(activity.isExpenseActivity, isFalse);
    });
  });
}
