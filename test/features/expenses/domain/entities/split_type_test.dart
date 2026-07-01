import 'package:flutter_test/flutter_test.dart';
import 'package:splito_flutter/features/expenses/domain/entities/split_type.dart';

void main() {
  group('SplitType', () {
    test('apiValue returns correct backend strings', () {
      expect(SplitType.equal.apiValue, 'EQUAL');
      expect(SplitType.exact.apiValue, 'EXACT');
      expect(SplitType.percentage.apiValue, 'PERCENTAGE');
      expect(SplitType.share.apiValue, 'SHARE');
    });

    test('fromApiValue parses valid strings', () {
      expect(SplitType.fromApiValue('EQUAL'), SplitType.equal);
      expect(SplitType.fromApiValue('EXACT'), SplitType.exact);
      expect(SplitType.fromApiValue('PERCENTAGE'), SplitType.percentage);
      expect(SplitType.fromApiValue('SHARE'), SplitType.share);
    });

    test('fromApiValue throws ArgumentError on unknown string', () {
      expect(
        () => SplitType.fromApiValue('INVALID'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
