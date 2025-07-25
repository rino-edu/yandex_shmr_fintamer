import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintamer/src/features/main_screen/widgets/offline_banner.dart';

void main() {
  testWidgets('OfflineBanner golden test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(),
        ),
      ),
    );

    await expectLater(
      find.byType(OfflineBanner),
      matchesGoldenFile('goldens/offline_banner.png'),
    );
  });
}