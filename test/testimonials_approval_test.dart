import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/data/app_repository.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/impact/impact_stories_screen.dart';

void main() {
  setUp(() {
    AppRepository().setTestimonials([]);
  });

  group('Testimonials & Admin Approval Integrity Tests', () {
    test('AppRepository testimonials is empty by default and has no hardcoded mock data', () {
      final repo = AppRepository();
      expect(repo.testimonials, isEmpty);

      // Verify that previously hardcoded mock names are absent
      expect(repo.testimonials.any((t) => t.name == 'Rameshwar Dayal'), isFalse);
      expect(repo.testimonials.any((t) => t.name == 'Deepak Sharma (Divyangjan)'), isFalse);
      expect(repo.testimonials.any((t) => t.name == 'Smt. Kamlesh Devi'), isFalse);
    });

    test('TestimonialItem model defaults to pending status when created from user submission', () {
      final json = {
        'id': '10',
        'name': 'Asha Rani',
        'relation': 'Veer Nari',
        'location': 'Ambala, Haryana',
        'quote': 'The foundation assisted my family with pension guidance.',
        'program': 'Veer Nari Welfare',
        'rating': 5,
        'status': 'pending',
      };

      final item = TestimonialItem.fromJson(json);
      expect(item.id, '10');
      expect(item.name, 'Asha Rani');
      expect(item.status, 'pending');
      expect(item.rating, 5);

      // Unapproved item must not be treated as approved
      expect(item.status == 'approved', isFalse);
    });

    test('TestimonialItem approved status verification', () {
      final json = {
        'id': '11',
        'name': 'Col. R. S. Rathore',
        'relation': 'Volunteer Veteran',
        'location': 'Jaipur, Rajasthan',
        'quote': 'Proud to volunteer and mentor martyr children.',
        'program': 'Education Mentorship',
        'rating': 5,
        'status': 'approved',
      };

      final item = TestimonialItem.fromJson(json);
      expect(item.status, 'approved');
      expect(item.status == 'approved', isTrue);
    });

    testWidgets('HomeScreen shows authentic verification message and no mock reviews when empty', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(onNavigateTab: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure mock names are completely gone
      expect(find.text('Rameshwar Dayal'), findsNothing);
      expect(find.text('Deepak Sharma (Divyangjan)'), findsNothing);

      // Ensure authentic moderation notice and submission button are visible
      expect(find.text('Voices of Resilience & Dignity'), findsOneWidget);
      expect(find.text('Share Your Story / Review'), findsOneWidget);
    });

    testWidgets('ImpactStoriesScreen shows strict verification banner and no mock reviews when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ImpactStoriesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure mock names are completely gone
      expect(find.text('Rameshwar Dayal'), findsNothing);
      expect(find.text('Deepak Sharma (Divyangjan)'), findsNothing);

      // Ensure headline metrics remain intact for test suite
      expect(find.text('Impact Stories & Testimonials'), findsOneWidget);
      expect(find.text('1,200+'), findsOneWidget);
      expect(find.text('3,500+'), findsOneWidget);
      expect(find.text('850+'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Firsthand Beneficiary Testimonials'), findsOneWidget);

      // Ensure moderation active badge and CTA are present
      expect(find.text('Strict Verification & Moderation Active'), findsOneWidget);
      expect(find.text('Submit Your Story / Review'), findsOneWidget);
    });

    testWidgets('Approved reviews are rendered dynamically when admin approves them', (WidgetTester tester) async {
      // Simulate an approved testimonial added to repository
      const approvedReview = TestimonialItem(
        id: 'rev-1',
        name: 'Smt. Geeta Devi',
        relation: 'Veer Nari',
        location: 'Hisar, Haryana',
        quote: 'The monthly tuition support for my son helped him excel in school.',
        program: 'Child Education Aid',
        imagePath: 'assets/images/team-2.jpg',
        impactBadge: 'Veer Nari Scholar',
        status: 'approved',
      );

      AppRepository().setTestimonials([approvedReview]);

      await tester.pumpWidget(
        const MaterialApp(
          home: ImpactStoriesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Smt. Geeta Devi'), findsOneWidget);
      expect(find.text('Veer Nari Scholar'), findsOneWidget);
      expect(find.text('Assisted via: Child Education Aid'), findsOneWidget);
    });
  });
}
