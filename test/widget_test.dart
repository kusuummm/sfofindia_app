import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/models/auth_user_model.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShaheedFoundationApp());
    expect(find.text('SHAHEED FOUNDATION'), findsWidgets);
  });

  testWidgets('App starts on Home tab and displays Login button', (WidgetTester tester) async {
    await tester.pumpWidget(const ShaheedFoundationApp());
    await tester.pumpAndSettle();

    // Verify Home tab is active and header & login elements are present
    expect(find.text('SHAHEED FOUNDATION'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
  });

  test('AuthService handles offline demo admin login and logout', () async {
    final auth = AuthService();
    expect(auth.isAuthenticated, isFalse);

    final success = await auth.login(
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
    );

    expect(success, isTrue);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.isAdmin, isTrue);
    expect(auth.currentUser?.username, 'admin');

    auth.logout();
    expect(auth.isAuthenticated, isFalse);
    expect(auth.role, UserRole.guest);
  });

  test('AuthService handles offline demo member login and logout', () async {
    final auth = AuthService();
    expect(auth.isAuthenticated, isFalse);

    final success = await auth.login(
      username: 'MBR0001',
      password: 'member123',
      role: UserRole.member,
    );

    expect(success, isTrue);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.isMember, isTrue);
    expect(auth.currentUser?.username, 'MBR0001');

    auth.logout();
    expect(auth.isAuthenticated, isFalse);
  });
}
