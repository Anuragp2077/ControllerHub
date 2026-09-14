import 'package:flutter_test/flutter_test.dart';

import 'package:controllerhub_mobile/main.dart';

void main() {
  testWidgets(
    'ControllerHub app loads',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ControllerHubApp(),
      );

      expect(
        find.text('ControllerHub'),
        findsOneWidget,
      );
    },
  );
}