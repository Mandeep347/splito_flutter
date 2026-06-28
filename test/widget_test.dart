import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/app.dart';

void main() {
  testWidgets('App initialization compile test', (WidgetTester tester) async {
    // Build our app and trigger a frame within ProviderScope.
    await tester.pumpWidget(
      const ProviderScope(
        child: SplitoApp(),
      ),
    );
  });
}
