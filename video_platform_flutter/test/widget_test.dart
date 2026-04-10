import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_platform_flutter/app.dart';

void main() {
  testWidgets('App bootstraps with a loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
