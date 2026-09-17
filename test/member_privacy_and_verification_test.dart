import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/member/member_verify_screen.dart';
import 'package:flutter_application_1/screens/member/member_portal_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  testWidgets('MemberVerifyScreen is clean and empty by default when not logged in', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MemberVerifyScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Should display title and Member Portal Access banner
    expect(find.text('Member Verification'), findsWidgets);
    expect(find.text('Enrolled Member Portal'), findsOneWidget);
    expect(find.text('Member Login'), findsOneWidget);
    expect(find.text('Join Us / Apply'), findsOneWidget);

    // 2. Search box should NOT have any member preloaded
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, isEmpty);

    // 3. Should show official verification guide card, NOT any member's personal card
    expect(find.text('Official Registry Verification'), findsOneWidget);
    expect(find.text('OFFICIALLY VERIFIED'), findsNothing);
    expect(find.text('Rajiv Sharma'), findsNothing);
    expect(find.text('Kusum Rathore'), findsNothing);

    // 4. When clicking a sample chip or searching an ID, member card appears
    await tester.tap(find.text('SFOF-2024-0012'));
    await tester.pumpAndSettle();

    expect(find.text('OFFICIALLY VERIFIED'), findsOneWidget);
    expect(find.text('SFOF-2024-0012'), findsWidgets);
  });

  testWidgets('MemberPortalScreen cleanly requests login if accessed while logged out', (WidgetTester tester) async {
    expect(AuthService().isAuthenticated, isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: MemberPortalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Should NOT display any personal member documents or fallback name
    expect(find.text('Member Login Required'), findsOneWidget);
    expect(find.text('Log In as Member'), findsOneWidget);
    expect(find.text('Kusum Rathore'), findsNothing);
  });
}
