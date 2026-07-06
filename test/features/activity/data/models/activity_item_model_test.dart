import 'package:flutter_test/flutter_test.dart';
import 'package:splito_flutter/features/activity/data/models/activity_item_model.dart';

void main() {
  group('ActivityItemModel.toEntity', () {
    test('derives correct description for EXPENSE_CREATED', () {
      const model = ActivityItemModel(
        type: 'EXPENSE_CREATED',
        actor: 'Mandeep',
        createdAt: '2026-05-20T10:00:00Z',
      );

      final entity = model.toEntity(groupId: 'group-1', index: 0);

      expect(entity.description, equals('Mandeep added an expense'));
    });

    test('derives correct description for SETTLEMENT_RECORDED', () {
      const model = ActivityItemModel(
        type: 'SETTLEMENT_RECORDED',
        actor: 'Mandeep',
        createdAt: '2026-05-20T10:00:00Z',
      );

      final entity = model.toEntity(groupId: 'group-1', index: 0);

      expect(entity.description, equals('Mandeep recorded a payment'));
    });

    test('derives entityType expense for EXPENSE_ prefix', () {
      const model = ActivityItemModel(
        type: 'EXPENSE_REVERSED',
        actor: 'Mandeep',
        createdAt: '2026-05-20T10:00:00Z',
      );

      final entity = model.toEntity(groupId: 'group-1', index: 0);

      expect(entity.entityType, equals('expense'));
    });

    test('derives entityType settlement for SETTLEMENT_ prefix', () {
      const model = ActivityItemModel(
        type: 'SETTLEMENT_RECORDED',
        actor: 'Mandeep',
        createdAt: '2026-05-20T10:00:00Z',
      );

      final entity = model.toEntity(groupId: 'group-1', index: 0);

      expect(entity.entityType, equals('settlement'));
    });

    test('derives entityType null for GROUP_ prefix', () {
      const model = ActivityItemModel(
        type: 'GROUP_UPDATED',
        actor: 'Mandeep',
        createdAt: '2026-05-20T10:00:00Z',
      );

      final entity = model.toEntity(groupId: 'group-1', index: 0);

      expect(entity.entityType, isNull);
    });

    test('parses created_at ISO string to DateTime', () {
      const json = {
        'type': 'EXPENSE_CREATED',
        'actor': 'Mandeep',
        'created_at': '2026-05-20T10:00:00Z',
      };

      final model = ActivityItemModel.fromJson(json);

      expect(model.createdAt, equals('2026-05-20T10:00:00Z'));
    });
  });
}
