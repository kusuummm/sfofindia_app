import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/impact/impact_stories_screen.dart';

void main() {
  testWidgets('ImpactStoriesScreen renders impact metrics and verified testimonials', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ImpactStoriesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impact Stories & Testimonials'), findsOneWidget);
    expect(find.text('1,200+'), findsOneWidget);
    expect(find.text('3,500+'), findsOneWidget);
    expect(find.text('850+'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Firsthand Beneficiary Testimonials'), findsOneWidget);
  });
}
