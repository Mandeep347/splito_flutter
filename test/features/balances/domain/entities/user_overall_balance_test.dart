import 'package:flutter_test/flutter_test.dart';
import 'package:splito_flutter/features/balances/domain/entities/user_overall_balance.dart';

void main() {
  group('UserOverallBalance', () {
    test('youOwe is true when netAmount is positive', () {
      const balance = UserOverallBalance(
        counterpartUserId: 'user-2',
        counterpartName: 'Rahul Kumar',
        netAmount: 500.0,
        currency: 'INR',
      );
      expect(balance.youOwe, isTrue);
      expect(balance.theyOwe, isFalse);
    });

    test('theyOwe is true when netAmount is negative', () {
      const balance = UserOverallBalance(
        counterpartUserId: 'user-2',
        counterpartName: 'Rahul Kumar',
        netAmount: -300.0,
        currency: 'INR',
      );
      expect(balance.theyOwe, isTrue);
      expect(balance.youOwe, isFalse);
    });

    test('absAmount returns absolute value', () {
      const balance = UserOverallBalance(
        counterpartUserId: 'user-2',
        counterpartName: 'Rahul Kumar',
        netAmount: -300.0,
        currency: 'INR',
      );
      expect(balance.absAmount, closeTo(300.0, 0.001));
    });
  });
}
