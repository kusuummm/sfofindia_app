import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/member/member_portal_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/models/auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService().logout();
  });

  testWidgets('MemberPortalScreen Security Tab renders dual-mode authorization and validates inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Set authenticated member session
    const member = AuthUser(
      id: '4',
      username: 'MBR0004',
      name: 'Kusum Rathore',
      email: 'kusumrathore662@gmail.com',
      role: UserRole.member,
      memberUserId: 'MBR0004',
      phone: '+91 63500 45224',
      status: 'active',
    );
    AuthService().setOfflineSession(member);

    await tester.pumpWidget(
      const MaterialApp(
        home: MemberPortalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Member Portal loaded
    expect(find.text('Member Portal'), findsOneWidget);

    // Navigate to Security & KYC Tab (Tab index 4)
    final securityTab = find.text('Security & KYC');
    expect(securityTab, findsOneWidget);
    await tester.tap(securityTab);
    await tester.pumpAndSettle();

    // Verify Security Tab Header and Policy Notice
    expect(find.text('Account Security & Password'), findsOneWidget);
    expect(find.text('Two-Factor Authorization Enforced'), findsOneWidget);
    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('Email OTP Code'), findsOneWidget);

    // Initial state: Mode is 'Current Password'
    expect(find.text('Current Account Password *'), findsOneWidget);

    // Test Validation 1: Submit with empty fields
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);

    // Switch to Email OTP Mode
    await tester.tap(find.text('Email OTP Code'));
    await tester.pumpAndSettle();

    // Verify Email OTP UI elements
    expect(find.text('Current Account Password *'), findsNothing);
    expect(find.textContaining('Registered Email:'), findsOneWidget);
    expect(find.text('Send 6-Digit OTP Code'), findsOneWidget);
    expect(find.text('Enter 6-Digit OTP Code *'), findsOneWidget);

    // Tap Send OTP
    await tester.tap(find.text('Send 6-Digit OTP Code'));
    await tester.pumpAndSettle();

    // Switch back to Current Password Mode
    await tester.tap(find.text('Current Password'));
    await tester.pumpAndSettle();
    expect(find.text('Current Account Password *'), findsOneWidget);
  });
}
