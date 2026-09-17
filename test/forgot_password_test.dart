import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/auth/forgot_password_screen.dart';
import 'package:flutter_application_1/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService().logout();
  });

  testWidgets('ForgotPasswordScreen completes full 3-step Email OTP recovery and auto-login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(enableTimer: false),
      ),
    );
    await tester.pumpAndSettle();

    // --- STEP 1: EMAIL INPUT ---
    expect(find.text('Password Recovery'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Registered Email Address'), findsOneWidget);
    expect(find.text('Send 6-Digit OTP'), findsOneWidget);

    // 1.1 Test invalid email
    await tester.tap(find.byKey(const Key('forgot_send_otp_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your registered email address.'), findsOneWidget);

    // 1.2 Enter valid admin email using quick fill chip
    await tester.tap(find.text('Admin Email (admin@example.com)'));
    await tester.pumpAndSettle();

    // 1.3 Submit to send OTP
    await tester.tap(find.byKey(const Key('forgot_send_otp_btn')));
    await tester.pumpAndSettle();

    // --- STEP 2: 6-DIGIT OTP VERIFICATION ---
    expect(find.text('Verify 6-Digit OTP'), findsOneWidget);
    expect(find.text('Enter 6-Digit Verification Code'), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);

    // 2.1 Test incomplete OTP validation
    await tester.tap(find.byKey(const Key('forgot_verify_otp_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter the complete 6-digit OTP code.'), findsOneWidget);

    // 2.2 Enter 6-digit OTP
    await tester.enterText(find.byKey(const Key('forgot_otp_input')), '123456');
    await tester.pumpAndSettle();

    // 2.3 Submit OTP
    await tester.tap(find.byKey(const Key('forgot_verify_otp_btn')));
    await tester.pumpAndSettle();

    // --- STEP 3: SET NEW PASSWORD ---
    expect(find.text('Set New Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(find.text('Set Password & Log In'), findsOneWidget);

    // 3.1 Test short password
    await tester.enterText(find.byKey(const Key('forgot_new_password_input')), '123');
    await tester.enterText(find.byKey(const Key('forgot_confirm_password_input')), '123');
    await tester.tap(find.byKey(const Key('forgot_set_password_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 6 characters long.'), findsOneWidget);

    // 3.2 Test mismatched passwords
    await tester.enterText(find.byKey(const Key('forgot_new_password_input')), 'newPassword123');
    await tester.enterText(find.byKey(const Key('forgot_confirm_password_input')), 'differentPassword');
    await tester.tap(find.byKey(const Key('forgot_set_password_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match. Please re-enter.'), findsOneWidget);

    // 3.3 Enter matching valid password & submit
    await tester.enterText(find.byKey(const Key('forgot_new_password_input')), 'newPassword123');
    await tester.enterText(find.byKey(const Key('forgot_confirm_password_input')), 'newPassword123');
    await tester.tap(find.byKey(const Key('forgot_set_password_btn')));
    await tester.pumpAndSettle();

    // --- STEP 4: VERIFY AUTO-LOGIN ---
    // User should be logged in as admin and navigated to AdminDashboardScreen
    expect(AuthService().isAuthenticated, isTrue);
    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });
}
