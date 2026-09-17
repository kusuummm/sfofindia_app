import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/services/services_screen.dart';
import 'package:flutter_application_1/screens/donation/donation_screen.dart';
import 'package:flutter_application_1/screens/gallery/gallery_screen.dart';
import 'package:flutter_application_1/screens/about/about_screen.dart';
import 'package:flutter_application_1/screens/member/member_portal_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/models/auth_user_model.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  const testViewports = [
    Size(320, 600),   // Ultra-compact mobile
    Size(360, 750),   // Standard mobile
    Size(412, 915),   // Large modern smartphone
    Size(768, 1024),  // Tablet portrait
    Size(1280, 800),  // Desktop web / landscape
  ];

  testWidgets('MainShell renders adaptively on mobile bottom bar and desktop sidebar', (WidgetTester tester) async {
    // 1. Mobile viewport (<950)
    tester.view.physicalSize = const Size(360, 750);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('SHAHEED FOUNDATION'), findsWidgets);

    // 2. Desktop viewport (>=950)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    // Desktop sidebar should be active, no BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.text('MAIN NAVIGATION'), findsOneWidget);
    expect(find.text('PORTAL & MISSIONS'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('HomeScreen renders across all viewports without layout overflow', (WidgetTester tester) async {
    for (final size in testViewports) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(onNavigateTab: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SHAHEED FOUNDATION'), findsWidgets);
      expect(find.text('Standing With Those Who Gave Everything'), findsOneWidget);
      expect(find.text('Direct Bank Transfer / UPI'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('MemberPortalScreen renders across all viewports without layout overflow', (WidgetTester tester) async {
    await AuthService().login(
      username: 'MBR0001',
      password: 'member123',
      role: UserRole.member,
    );

    for (final size in testViewports) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: MemberPortalScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Member Portal & Services'), findsOneWidget);
      expect(find.text('TOTAL DONATED'), findsOneWidget);
      expect(find.text('80G TAX SAVINGS'), findsOneWidget);
      expect(find.text('OFFICIAL DOCUMENTS'), findsOneWidget);
      expect(find.text('KYC VERIFICATION'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('ServicesScreen renders cleanly across viewports', (WidgetTester tester) async {
    for (final size in [const Size(320, 600), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(home: ServicesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Our Services'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('DonationScreen renders cleanly across viewports', (WidgetTester tester) async {
    for (final size in [const Size(320, 600), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(home: DonationScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Donation'), findsWidgets);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('GalleryScreen renders cleanly across viewports', (WidgetTester tester) async {
    for (final size in [const Size(320, 600), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Photo Gallery'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('AboutScreen renders cleanly across viewports', (WidgetTester tester) async {
    for (final size in [const Size(320, 600), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
      await tester.pumpAndSettle();
      expect(find.text('About Us'), findsWidgets);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
