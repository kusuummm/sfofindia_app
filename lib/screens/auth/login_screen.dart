import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth_user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../member/member_portal_screen.dart';
import '../widgets/server_connection_dialog.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole? initialRole;
  const LoginScreen({super.key, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Email / ID and Password.'),
          backgroundColor: AppTheme.flameRed,
        ),
      );
      return;
    }

    final success = await _authService.login(
      username: identifier,
      password: password,
      role: null, // Unified login: backend/service auto-detects admin vs member
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${_authService.currentUser?.name ?? "User"}! Signed in as ${_authService.role.displayName}. ${_authService.isLiveBackend ? "(Live Server)" : "(Offline Mode)"}',
          ),
          backgroundColor: AppTheme.wreathGreen,
        ),
      );

      // Navigate to respective dashboard according to authenticated role
      if (_authService.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (_authService.isMember) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.lastError ?? 'Sign in failed. Please check your credentials.'),
          backgroundColor: AppTheme.flameRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portal Login'),
        elevation: 0,
        backgroundColor: AppTheme.secondaryNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded),
            tooltip: 'Server Connection Settings',
            onPressed: () => ServerConnectionDialog.show(context).then((_) => setState(() {})),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _authService,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.secondaryNavy, AppTheme.navyDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppConstants.logoPath,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shield,
                            size: 40,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Shaheed Foundation of India',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Unified Authentication Portal',
                        style: TextStyle(
                          color: AppTheme.primaryGoldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unified Login Card (No tabs)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sign In to Your Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your registered Email or Member ID to continue',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Email / ID Field
                          TextField(
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email / Member ID',
                              hintText: 'Enter email or ID',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(
                                      initialEmail: _identifierController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppTheme.secondaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Unified Sign In Button
                          ElevatedButton(
                            onPressed: _authService.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _authService.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign In',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'Members and Administrators can sign in directly with their credentials.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => ServerConnectionDialog.show(context).then((_) => setState(() {})),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.warmCreamLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: _authService.isLiveBackend || ApiService().isBackendReachable
                                        ? AppTheme.wreathGreen
                                        : Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Server: ${ApiService().baseUrl}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.secondaryNavy, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.tune_rounded, size: 14, color: AppTheme.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
