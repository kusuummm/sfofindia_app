import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../about/about_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../member/member_portal_screen.dart';
import '../member/member_verify_screen.dart';
import '../team/our_team_screen.dart';
import '../impact/impact_stories_screen.dart';
import '../blog/blog_screen.dart';
import '../legal/legal_compliance_screen.dart';
import '../memorial/memorial_tributes_screen.dart';
import '../services/blood_donor_screen.dart';
import '../../core/utils/url_helper.dart';
import '../../core/localization/app_locale.dart';
import 'server_connection_dialog.dart';
import 'logout_dialog.dart';



class DrawerMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectTab;

  const DrawerMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final locale = AppLocale();

    return ListenableBuilder(
      listenable: Listenable.merge([authService, locale]),
      builder: (context, _) {
        final isAuthenticated = authService.isAuthenticated;
        final user = authService.currentUser;
        final isAdmin = authService.isAdmin;
        final isMember = authService.isMember;
        final isHi = locale.isHindi;

        return Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.navyDark, AppTheme.secondaryNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppConstants.logoPath,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.shield,
                              size: 40,
                              color: AppTheme.secondaryNavy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppConstants.appName,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                AppConstants.legalType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // User Authentication Status Card inside Header (Clickable for Admin / Member)
                    if (isAuthenticated && user != null) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final nav = Navigator.of(context);
                            nav.pop();
                            if (isAdmin) {
                              nav.push(
                                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                              );
                            } else {
                              nav.push(
                                MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primaryGold,
                                  child: Icon(
                                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                                    color: AppTheme.secondaryNavy,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              user.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white60,
                                            size: 11,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${user.role.displayName} • ${user.username}',
                                        style: const TextStyle(
                                          color: AppTheme.primaryGoldLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Sign Out',
                                  icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    LogoutDialog.show(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 16, color: AppTheme.secondaryNavy),
                              SizedBox(width: 8),
                              Text(
                                'Member & Admin Login Portal',
                                style: TextStyle(
                                  color: AppTheme.secondaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ROLE SPECIFIC PORTAL SHORTCUTS
              if (isAdmin) ...[
                _drawerItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin CMS Dashboard',
                  iconColor: AppTheme.flameRed,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),
                const Divider(indent: 20, endIndent: 20),
              ],

              if (isMember) ...[
                _drawerItem(
                  context,
                  icon: Icons.badge_rounded,
                  title: 'My Member Portal & ID Card',
                  iconColor: AppTheme.primaryGoldDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                    );
                  },
                ),
                const Divider(indent: 20, endIndent: 20),
              ],

              // SECTION 1: CORE NAVIGATION
              _sectionHeader('CORE NAVIGATION'),
              _drawerItem(
                context,
                icon: Icons.home_rounded,
                title: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(0);
                },
              ),
              _drawerItem(
                context,
                icon: Icons.handshake_rounded,
                title: 'Support Services',
                isSelected: selectedIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(1);
                },
              ),
              _drawerItem(
                context,
                icon: Icons.volunteer_activism_rounded,
                title: 'Donate (80G Tax Benefit)',
                isSelected: selectedIndex == 2,
                iconColor: AppTheme.primaryGold,
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(2);
                },
              ),
              _drawerItem(
                context,
                icon: Icons.card_membership_rounded,
                title: 'Membership & Verification',
                isSelected: selectedIndex == 3,
                onTap: () {
                  Navigator.pop(context);
                  onSelectTab(3);
                },
              ),

              const Divider(indent: 20, endIndent: 20),

              // SECTION 2: TRANSPARENCY & LEGAL COMPLIANCE
              _sectionHeader('TRANSPARENCY & LEGAL COMPLIANCE'),
              _drawerItem(
                context,
                icon: Icons.description_rounded,
                title: 'Our Documents & 80G',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.policy_rounded,
                title: 'Legal, Privacy & 80G Policy',
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalComplianceScreen()),
                  );
                },
              ),

              const Divider(indent: 20, endIndent: 20),

              // SECTION 3: COMMUNITY, MEDIA & STORIES
              _sectionHeader(isHi ? 'स्मृति पटल, समाज एवं मीडिया' : 'COMMUNITY, MEDIA & STORIES'),
              _drawerItem(
                context,
                icon: Icons.newspaper_rounded,
                title: 'News & Press Releases',
                iconColor: const Color(0xFF4F46E5),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlogScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.flare_rounded,
                title: 'Amar Jyoti & Martyr Tributes',
                iconColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemorialTributesScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.bloodtype_rounded,
                title: 'Emergency Blood Network',
                iconColor: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BloodDonorScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.military_tech_rounded,
                title: 'Impact Stories & Testimonials',
                iconColor: AppTheme.primaryGoldDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImpactStoriesScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.photo_library_rounded,
                title: 'Gallery & Events',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.info_outline_rounded,
                title: 'About Us & Mission',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.groups_rounded,
                title: 'Our Team & Leadership',
                iconColor: AppTheme.secondaryNavy,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OurTeamScreen()),
                  );
                },
              ),

              const Divider(indent: 20, endIndent: 20),

              // SECTION 4: MEMBERSHIP & HELP
              _sectionHeader('MEMBERSHIP & VERIFICATION'),
              if (!isAuthenticated) ...[
                _drawerItem(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'Login (Member / Admin)',
                  iconColor: AppTheme.secondaryNavy,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
              _drawerItem(
                context,
                icon: Icons.verified_user_rounded,
                title: 'Verification (Member ID & 80G)',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberVerifyScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.person_add_alt_1_rounded,
                title: 'Join Us (Member Apply)',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.headset_mic_rounded,
                title: 'Contact & Help Desk',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                icon: Icons.dns_outlined,
                title: 'Server Connection',
                iconColor: const Color(0xFF64748B),
                onTap: () {
                  Navigator.pop(context);
                  ServerConnectionDialog.show(context);
                },
              ),

              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  UrlHelper.launchPhoneCall(context, AppConstants.phone);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGold.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_in_talk, color: AppTheme.primaryGoldDark, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Helpline & Support',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGoldDark,
                              ),
                            ),
                            Text(
                              AppConstants.phoneDisplay,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.call, size: 18, color: AppTheme.primaryGoldDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isSelected ? AppTheme.secondaryNavy : AppTheme.textMuted),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.secondaryNavy : AppTheme.textDark,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.secondaryNavy.withAlpha(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      dense: true,
      onTap: onTap,
    );
  }
}
