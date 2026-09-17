import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'home/home_screen.dart';
import 'services/services_screen.dart';
import 'donation/donation_screen.dart';
import '../services/auth_service.dart';
import 'member/member_portal_screen.dart';
import 'member/member_verify_screen.dart';
import 'widgets/drawer_menu.dart';
import 'about/about_screen.dart';
import 'gallery/gallery_screen.dart';
import 'documents/documents_screen.dart';
import 'impact/impact_stories_screen.dart';
import 'team/our_team_screen.dart';
import 'auth/login_screen.dart';

class MemberTabWrapper extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const MemberTabWrapper({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final auth = AuthService();
        if (auth.isAuthenticated && auth.isMember) {
          return const MemberPortalScreen();
        }
        return MemberVerifyScreen(onNavigateTab: onNavigateTab);
      },
    );
  }
}

class MainShell extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onSelectTab),
      ServicesScreen(onNavigateTab: _onSelectTab),
      DonationScreen(onNavigateTab: _onSelectTab),
      MemberTabWrapper(onNavigateTab: _onSelectTab),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= Responsive.desktopMin;

        if (isDesktop) {
          return Scaffold(
            key: MainShell.scaffoldKey,
            body: Row(
              children: [
                // Desktop Brand Sidebar (260px)
                _buildDesktopSidebar(context),

                // Main Page View
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile & Tablet standard Shell
        return Scaffold(
          key: MainShell.scaffoldKey,
          drawer: DrawerMenu(
            selectedIndex: _currentIndex,
            onSelectTab: _onSelectTab,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onSelectTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.secondaryNavy,
              unselectedItemColor: AppTheme.textMuted,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.handshake_outlined),
                  activeIcon: Icon(Icons.handshake_rounded),
                  label: 'Services',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withAlpha(80),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppTheme.secondaryNavy, size: 20),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppTheme.primaryGold, size: 20),
                  ),
                  label: 'Donate',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.badge_outlined),
                  activeIcon: Icon(Icons.badge_rounded),
                  label: 'Members',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    final auth = AuthService();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header: Logo & Title
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    AppConstants.logoPath,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: AppTheme.secondaryNavy, size: 32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SHAHEED',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'FOUNDATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Primary Navigation Tabs
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'MAIN NAVIGATION',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _desktopNavItem(
                  title: 'Home',
                  icon: Icons.home_rounded,
                  index: 0,
                ),
                _desktopNavItem(
                  title: 'Services & Welfare',
                  icon: Icons.handshake_rounded,
                  index: 1,
                ),
                _desktopNavItem(
                  title: 'Donation & Support',
                  icon: Icons.favorite_rounded,
                  index: 2,
                  isDonation: true,
                ),
                _desktopNavItem(
                  title: 'Members & Portal',
                  icon: Icons.badge_rounded,
                  index: 3,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'PORTAL & MISSIONS',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _desktopQuickAction(
                  title: 'Impact Stories',
                  icon: Icons.military_tech_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpactStoriesScreen())),
                ),
                _desktopQuickAction(
                  title: 'Official Documents',
                  icon: Icons.description_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
                ),
                _desktopQuickAction(
                  title: 'Gallery & Media',
                  icon: Icons.photo_library_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                ),
                _desktopQuickAction(
                  title: 'About Foundation',
                  icon: Icons.info_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
                _desktopQuickAction(
                  title: 'Our Team & Leadership',
                  icon: Icons.groups_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OurTeamScreen())),
                ),
              ],
            ),
          ),

          // User Profile / Login status bar at bottom
          ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF071733),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: auth.isAuthenticated
                    ? Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryGold,
                            child: Text(
                              (auth.currentUser?.name ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.currentUser?.name ?? 'User',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  auth.isAdmin ? 'Admin' : 'Active Member',
                                  style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                            tooltip: 'Logout',
                            onPressed: () => auth.logout(),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: AppTheme.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.login, size: 16),
                          label: const Text('Member / Admin Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _desktopNavItem({
    required String title,
    required IconData icon,
    required int index,
    bool isDonation = false,
  }) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _onSelectTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDonation ? AppTheme.primaryGold : Colors.white.withAlpha(25))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDonation ? AppTheme.secondaryNavy : AppTheme.primaryGold)
                    : Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? (isDonation ? AppTheme.secondaryNavy : Colors.white)
                        : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDonation ? AppTheme.secondaryNavy : AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white54),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}
