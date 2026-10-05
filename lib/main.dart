import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/member/member_portal_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().restoreSession();
  runApp(const ShaheedFoundationApp());
}

class ShaheedFoundationApp extends StatelessWidget {
  const ShaheedFoundationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15),
          ),
          child: child ?? const SizedBox(),
        );
      },
      home: const AuthGate(),
    );
  }
}

/// Root authentication gate:
/// - If signed in: automatically directs to Member Portal (or Admin Dashboard)
/// - If not signed in: starts directly on the Login / Register screen with "View Website" browser option
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final auth = AuthService();
        if (auth.isAuthenticated) {
          if (auth.isAdmin) {
            return const AdminDashboardScreen();
          }
          return const MemberPortalScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
