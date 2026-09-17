import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter_application_1/screens/member/member_portal_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/models/auth_user_model.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  testWidgets('LoginScreen renders unified login form and forgot password dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In to Your Account'), findsOneWidget);
    expect(find.text('Email / Member ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Quick Demo Login Credentials'), findsNothing);
    expect(find.textContaining('Backend Connected'), findsNothing);

    // Open Forgot Password Screen
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Password Recovery'), findsOneWidget);
    expect(find.text('Send 6-Digit OTP'), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);

    // Tap Back to Sign In
    final backBtn = find.text('Back to Sign In');
    await tester.ensureVisible(backBtn);
    await tester.pumpAndSettle();
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.text('Password Recovery'), findsNothing);
  });

  testWidgets('MemberPortalScreen renders Digital ID Card and Certificate actions', (WidgetTester tester) async {
    // Setup member session
    await AuthService().login(
      username: 'MBR0001',
      password: 'member123',
      role: UserRole.member,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MemberPortalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Member Portal & Services'), findsOneWidget);
    expect(find.text('OFFICIAL MEMBERSHIP IDENTITY CARD'), findsOneWidget);

    // Switch to Documents tab to view certificate and tax receipt actions
    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();

    expect(find.text('Official Digital ID Card'), findsOneWidget);
    expect(find.text('Certificate of Appreciation & Association'), findsOneWidget);
    expect(find.text('Section 80G Tax Exemption Receipt'), findsOneWidget);
  });

  testWidgets('AdminDashboardScreen renders on small mobile and desktop viewports without overflow', (WidgetTester tester) async {
    for (final size in [const Size(320, 600), const Size(360, 750), const Size(412, 915), const Size(1024, 768)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await AuthService().login(
        username: 'admin',
        password: 'admin123',
        role: UserRole.admin,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('Pending Verifications'), findsOneWidget);
      expect(find.text('Total Donations'), findsOneWidget);
      expect(find.text('Campaigns'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
