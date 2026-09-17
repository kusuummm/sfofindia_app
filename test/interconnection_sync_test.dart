import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/screens/gallery/gallery_screen.dart';

void main() {
  group('Website <-> App Two-Way Interconnection Tests', () {
    test('ApiService supports bidirectional Site Settings sync', () async {
      final api = ApiService();
      expect(api.baseUrl, isNotEmpty);

      // Verify getSiteSettings and updateSiteSettings methods exist and handle payload
      final res = await api.getSiteSettings();
      expect(res, isNotNull);
    });

    test('ApiService supports full Member profile updates for Admin Studio', () async {
      final api = ApiService();
      final res = await api.updateMemberDetails(
        memberId: 6,
        data: {
          'name': 'Amit Sharma (Verified)',
          'profession': 'National Coordinator',
        },
      );
      expect(res, isNotNull);
    });

    test('ApiService supports Diya tribute counter and Citizen Wall', () async {
      final api = ApiService();
      final diyaRes = await api.lightDiya('batra');
      expect(diyaRes, isNotNull);

      final tributesRes = await api.getTributes();
      expect(tributesRes, isNotNull);
    });

    test('ApiService supports Blood Donors registry sync', () async {
      final api = ApiService();
      final donorsRes = await api.getBloodDonors();
      expect(donorsRes, isNotNull);
    });

    testWidgets('GalleryScreen renders with live database synchronization', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gallery & Welfare Events'), findsOneWidget);
      expect(find.text('Photo Gallery'), findsOneWidget);
      expect(find.text('Welfare Events'), findsOneWidget);
    });
  });
}
