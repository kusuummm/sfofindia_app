import '../widgets/animated_stat_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_repository.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../main_shell.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../member/member_portal_screen.dart';
import '../../core/utils/url_helper.dart';
import '../impact/impact_stories_screen.dart';
import '../../core/utils/responsive.dart';
import '../team/our_team_screen.dart';
import '../services/service_detail_screen.dart';



class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _sliderController = PageController();
  int _activeSlide = 0;
  List<Map<String, dynamic>> _homeCampaigns = [];
  Map<String, dynamic> _homeStats = {};
  List<Map<String, dynamic>> _homeActivities = [];
  List<TestimonialItem> _approvedTestimonials = [];

  ServiceType _getHomeServiceType(String id) {
    switch (id) {
      case 'financial':
        return ServiceType.financial;
      case 'education':
        return ServiceType.education;
      case 'medical':
      case 'disability':
        return ServiceType.medical;
      case 'employment':
      default:
        return ServiceType.employment;
    }
  }

  final List<Map<String, String>> _slides = [
    {
      'title': 'HONORING SACRIFICE.\nSUPPORTING FAMILIES.\nBUILDING HOPE.',
      'text':
          'At Shaheed Foundation of India, we stand beside the families of our martyrs, offering respect, support, and long-term assistance to help them live with dignity and security.',
      'btn1': "Support a Martyr's Family",
      'btn2': 'Join as a Volunteer',
      'img': AppConstants.soldierHero,
    },
    {
      'title': 'STANDING STRONG\nWITH THE FAMILIES OF\nOUR FALLEN HEROES',
      'text':
          'Shaheed Foundation of India is committed to honoring the brave souls who laid down their lives for the nation by ensuring care, dignity, and a secure future for their families.',
      'btn1': 'Support Disabled People',
      'btn2': 'Become a Volunteer',
      'img': AppConstants.armyHero2,
    },
    {
      'title': 'A STRONG SUPPORT\nSYSTEM FOR FAMILIES\nOF OUR MARTYRS',
      'text':
          'Dedicated to honoring the supreme sacrifice of our brave martyrs by supporting their families with dignity, care, and long-term security.',
      'btn1': 'Donate Now',
      'btn2': 'Join as a Volunteer',
      'img': AppConstants.armyHero,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final futures = await Future.wait([
        ApiService().getCampaigns(),
        ApiService().getAdminStats(),
        ApiService().getSiteSettings(),
        ApiService().getTestimonials(),
      ]);
      final campRes = futures[0];
      final statsRes = futures[1];
      final settingsRes = futures[2];
      final testRes = futures[3];

      if (mounted) {
        setState(() {
          if (campRes.isSuccess && campRes.data != null && campRes.data!.isNotEmpty) {
            _homeCampaigns = campRes.data!;
          }
          if (statsRes.isSuccess && statsRes.data != null && statsRes.data is Map) {
            final raw = statsRes.data as Map<String, dynamic>;
            if (raw['stats'] is Map) {
              _homeStats = Map<String, dynamic>.from(raw['stats']);
            } else {
              _homeStats = raw;
            }
            if (raw['activities'] is List) {
              _homeActivities = List<Map<String, dynamic>>.from(raw['activities']);
            }
          }
          if (testRes.isSuccess && testRes.data is List) {
            final List list = testRes.data as List;
            _approvedTestimonials = list.map((m) => TestimonialItem.fromJson(Map<String, dynamic>.from(m))).toList();
            AppRepository().setTestimonials(_approvedTestimonials);
          }
          if (settingsRes.isSuccess && settingsRes.data != null && settingsRes.data is Map) {
            final settings = settingsRes.data as Map;
            if (settings['slide1_title'] != null && settings['slide1_title'].toString().trim().isNotEmpty) {
              _slides[0]['title'] = settings['slide1_title'].toString();
            }
            if (settings['slide1_text'] != null && settings['slide1_text'].toString().trim().isNotEmpty) {
              _slides[0]['text'] = settings['slide1_text'].toString();
            }
            if (settings['slide1_btn1'] != null && settings['slide1_btn1'].toString().trim().isNotEmpty) {
              _slides[0]['btn1'] = settings['slide1_btn1'].toString();
            }
            if (settings['slide1_btn2'] != null && settings['slide1_btn2'].toString().trim().isNotEmpty) {
              _slides[0]['btn2'] = settings['slide1_btn2'].toString();
            }
            if (settings['slide2_title'] != null && settings['slide2_title'].toString().trim().isNotEmpty) {
              _slides[1]['title'] = settings['slide2_title'].toString();
            }
            if (settings['slide2_text'] != null && settings['slide2_text'].toString().trim().isNotEmpty) {
              _slides[1]['text'] = settings['slide2_text'].toString();
            }
            if (settings['slide3_title'] != null && settings['slide3_title'].toString().trim().isNotEmpty) {
              _slides[2]['title'] = settings['slide3_title'].toString();
            }
            if (settings['slide3_text'] != null && settings['slide3_text'].toString().trim().isNotEmpty) {
              _slides[2]['text'] = settings['slide3_text'].toString();
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    return RefreshIndicator(
      onRefresh: _fetchHomeData,
      color: AppTheme.secondaryNavy,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Website Two-Tier Header: Navy Topbar + Gold Navbar
          SliverToBoxAdapter(
            child: _buildWebsiteTwoTierHeader(context),
          ),

          // Main Page Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Website Hero Carousel (with bg.jpg pattern)
                _buildWebsiteHeroCarousel(),

                ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1.05 Dynamic Live Transparency & Impact Ticker
                      _buildLiveActivityTicker(),

                      const SizedBox(height: 14),

                      // 1.1 Quick Access Mobile Feature Dock (Exclusive to App)
                      _buildQuickFeatureDock(context),

                      const SizedBox(height: 25),

                      // 2. Website About Section ("Standing With Those Who Gave Everything")
                      _buildWebsiteAboutSection(context),

                      const SizedBox(height: 35),

                      // 3. Website Services Section ("How We Support Martyrs' Families")
                      _buildWebsiteServicesSection(context, repo),

                      const SizedBox(height: 35),

                      // 4. Website Features & Stats (2x2 Gold/Navy alternating blocks)
                      _buildWebsiteFeaturesSection(context),

                      const SizedBox(height: 35),

                      // 5. Website Featured Campaigns (3 donation items with progress bars)
                      _buildWebsiteDonationCampaigns(),

                      const SizedBox(height: 35),

                      // 5.1 Beneficiary Impact Stories & Voices (matching testimonial.html)
                      _buildWebsiteTestimonialsSection(context, repo),

                      const SizedBox(height: 35),

                      // 6. Direct Axis Bank Transfer Section (from website donation.php)
                      _buildWebsiteBankDetails(context),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // 7. Website Footer Section (Navy & Maroon with quick links & gallery)
                _buildWebsiteFooter(context, repo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1.05 Live Dynamic Activity & Transparency Ticker ---
  Widget _buildLiveActivityTicker() {
    final acts = _homeActivities.isNotEmpty
        ? _homeActivities
        : [
            {
              'type': 'donation',
              'text': 'Col. Gurmeet Singh contributed \u20B95,000 to Martyr Emergency Relief',
            },
            {
              'type': 'scholarship',
              'text': 'Education scholarship approved for martyr children in Rajasthan',
            },
            {
              'type': 'member',
              'text': 'New verified foundation member joined from Chandigarh chapter',
            },
          ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.secondaryNavy.withAlpha(25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.white, size: 7),
                SizedBox(width: 3),
                Text(
                  'LIVE',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 20,
              child: PageView.builder(
                itemCount: acts.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, idx) {
                  final act = acts[idx];
                  final text = act['text']?.toString() ?? 'Community Welfare Update';
                  final iconType = act['type']?.toString() ?? 'info';
                  IconData icon = Icons.info_outline;
                  Color iconColor = AppTheme.secondaryNavy;

                  if (iconType == 'donation') {
                    icon = Icons.favorite_rounded;
                    iconColor = AppTheme.primaryGoldDark;
                  } else if (iconType == 'tribute') {
                    icon = Icons.local_fire_department_rounded;
                    iconColor = AppTheme.flameRed;
                  } else if (iconType == 'blood_donor') {
                    icon = Icons.water_drop_rounded;
                    iconColor = const Color(0xFFE53935);
                  }

                  return Row(
                    children: [
                      Icon(icon, size: 13, color: iconColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Topbar & Navbar exactly like sfofindia.com ---
  Widget _buildWebsiteTwoTierHeader(BuildContext context) {
    return Column(
      children: [
        // Topbar: Navy Blue #0A1F44 - Fully Responsive Header
        Container(
          color: AppTheme.secondaryNavy,
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isCompact = width < 480;
                final isVeryCompact = width < 360;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Hamburger Menu Button (hidden on desktop where sidebar is present)
                      if (width < 950) ...[
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                          tooltip: 'Open Menu',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => MainShell.openDrawer(),
                        ),
                        SizedBox(width: isCompact ? 6 : 10),
                      ],

                      // Logo
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          AppConstants.logoPath,
                          height: isCompact ? 28 : 34,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shield,
                            size: 26,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                      ),
                      SizedBox(width: isCompact ? 8 : 10),

                      // Foundation Name & Registration - 100% RESPONSIVE & NEVER SPLITS INTO MULTIPLE LINES
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SHAHEED FOUNDATION',
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppTheme.primaryGold,
                                  fontSize: isCompact ? 13.5 : 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isVeryCompact
                                  ? 'Section 8 Registered NGO'
                                  : 'Section 8 Registered Non-Profit • Govt of India',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isCompact ? 8.5 : 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Auth / Portal Button
                      ListenableBuilder(
                        listenable: AuthService(),
                        builder: (context, _) {
                          final auth = AuthService();
                          if (auth.isAuthenticated) {
                            final isAdmin = auth.isAdmin;
                            return InkWell(
                              onTap: () {
                                if (isAdmin) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isAdmin ? AppTheme.flameRed : AppTheme.primaryGold,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAdmin ? Icons.admin_panel_settings : Icons.badge,
                                      size: 13,
                                      color: isAdmin ? Colors.white : AppTheme.textDark,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      isAdmin
                                          ? (isCompact ? 'CMS' : 'Admin CMS')
                                          : (isCompact ? 'Portal' : 'My Portal'),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin ? Colors.white : AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 6 : 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.login, size: 12, color: AppTheme.textDark),
                                  SizedBox(width: 3),
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Contact / Call button (shown when not ultra-compact)
                      if (!isVeryCompact) ...[
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () => UrlHelper.launchPhoneCall(context, AppConstants.phone),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 6 : 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone, size: 12, color: Colors.white),
                                if (!isCompact) ...[
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Call',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Navbar: Gold #C89B3C with quick horizontal navigation chips
        Container(
          color: AppTheme.primaryGold,
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              _navChip('Home', isActive: true, onTap: () {}),
              _navChip('About', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }),
              _navChip('Our Team', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OurTeamScreen()));
              }),
              _navChip('Services', onTap: () => widget.onNavigateTab(1)),
              _navChip('Donation', onTap: () => widget.onNavigateTab(2)),
              _navChip('Our Documents', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              }),
              _navChip('Gallery & Events', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
              }),
              _navChip('Join Us', isButton: true, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberApplyScreen()));
              }),
              _navChip(
                AuthService().isAuthenticated
                    ? (AuthService().isAdmin ? 'Admin Dashboard' : 'Member Portal')
                    : 'Portal Login',
                isButton: true,
                onTap: () {
                  if (AuthService().isAdmin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  } else if (AuthService().isMember) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              _navChip('Contact', onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navChip(String label, {bool isActive = false, bool isButton = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isButton
                ? AppTheme.secondaryNavy
                : (isActive ? Colors.white : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isButton
                  ? Colors.white
                  : (isActive ? AppTheme.secondaryNavy : AppTheme.textDark),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. Hero Header Carousel matching website with bg.jpg ---
  Widget _buildWebsiteHeroCarousel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.warmCreamLight,
        image: DecorationImage(
          image: AssetImage(AppConstants.bgPattern),
          fit: BoxFit.cover,
          opacity: 0.35,
        ),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: ResponsiveContainer(
        child: LayoutBuilder(
          builder: (context, heroConstraints) {
            final isCompact = heroConstraints.maxWidth < 400;
            final imageHeight = isCompact ? 130.0 : (heroConstraints.maxWidth < 600 ? 150.0 : 180.0);
            final carouselHeight = isCompact ? 285.0 : (heroConstraints.maxWidth < 600 ? 305.0 : 330.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: carouselHeight,
                  child: PageView.builder(
                    controller: _sliderController,
                    onPageChanged: (idx) => setState(() => _activeSlide = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Carousel Image with rounded corners
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                slide['img']!,
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Image.asset(
                                  AppConstants.armyHero,
                                  height: imageHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    height: imageHeight,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.secondaryNavy,
                                    AppTheme.navySoft,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.military_tech_rounded,
                                      size: 48,
                                      color: AppTheme.primaryGold,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      AppConstants.appName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Carousel Title
                      Text(
                        slide['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Carousel Text
                      Text(
                        slide['text']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Two Action Buttons (Gold & Navy)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 9.5),
                                elevation: 0,
                              ),
                              onPressed: () => widget.onNavigateTab(2),
                              child: Text(
                                slide['btn1']!,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryNavy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 9.5),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MemberApplyScreen()),
                                );
                              },
                              child: Text(
                                slide['btn2']!,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (idx) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 5,
                width: _activeSlide == idx ? 24 : 8,
                decoration: BoxDecoration(
                  color: _activeSlide == idx
                      ? AppTheme.primaryGold
                      : AppTheme.secondaryNavy.withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      );
    },
  ),
),
);
  }

  // --- 3. About Section matching website ---
  Widget _buildWebsiteAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Tag
          _sectionTitleTag('ABOUT SHAHEED FOUNDATION OF INDIA'),
          const SizedBox(height: 8),

          const Text(
            'Standing With Those Who Gave Everything',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Shaheed Foundation of India is a non-profit organization dedicated to supporting the families of brave martyrs who sacrificed their lives for the nation. Our mission is to ensure that no martyr’s family ever feels alone, forgotten, or helpless.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),

          // About Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppConstants.aboutImage,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 180,
                color: AppTheme.warmCream,
                child: const Center(
                  child: Icon(Icons.groups, size: 50, color: AppTheme.primaryGold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // What We Do Checklist
          const Text(
            'What We Do',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),

          _checkItem('Financial assistance for martyrs’ families'),
          _checkItem('Education and healthcare support'),
          _checkItem('Employment and skill development programs'),
          _checkItem('Emergency relief and crisis support'),

          const SizedBox(height: 12),

          // Emotional Quote
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warmCream,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppTheme.primaryGold, width: 4),
              ),
            ),
            child: const Text(
              '“A nation that honors its martyrs must stand with their families.”',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Gold Donation Box (Exact website component)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text(
                  'Your contribution helps us provide dignity, care, and hope to the families of our martyrs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: () => widget.onNavigateTab(2),
                  child: const Text('Donate Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Services Section ("How We Support Martyrs' Families") ---
  Widget _buildWebsiteServicesSection(BuildContext context, AppRepository repo) {
    return Container(
      color: AppTheme.warmCreamLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleTag('SERVICES'),
          const SizedBox(height: 6),

          const Text(
            'How We Support Martyrs’ Families',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),

          const Text(
            'We stand beside the families of our brave martyrs by providing financial, educational, medical, and emotional support to help them live with dignity and security.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),

          // 4 Service Cards
          ...repo.services.map((s) {
            final sType = _getHomeServiceType(s.id);
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(
                      serviceType: sType,
                      onNavigateTab: widget.onNavigateTab,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(s.icon, color: AppTheme.primaryGoldDark, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...s.benefits.take(3).map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check,
                                  size: 15, color: AppTheme.primaryGold),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.textDark),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppTheme.primaryGoldDark,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailScreen(
                              serviceType: sType,
                              onNavigateTab: widget.onNavigateTab,
                            ),
                          ),
                        );
                      },
                      icon: const Text(
                        'Read More & Apply',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      label: const Icon(Icons.arrow_forward, size: 14),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 5. Features & Stats Section (Exact 2x2 Alternating Grid from index.php) ---
  Widget _buildWebsiteFeaturesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleTag('WHY SUPPORT SHAHEED FAMILIES'),
          const SizedBox(height: 6),

          const Text(
            'Because Their Sacrifice Deserves Our Support',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'While we sleep safely in our homes, a soldier stands guard at the borders of our nation. When a family loses a son, husband, or father in the service of the country, it becomes our collective responsibility to stand by them with compassion, respect, and support.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.35),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warmCream,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppTheme.primaryGold, width: 4),
              ),
            ),
            child: const Text(
              '“The sacrifice of our martyrs is eternal; their families are our responsibility.” 🇮🇳',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 2x2 Grid with exact alternating Gold/Navy styling from the website
          Row(
            children: [
              // Block 1: Gold #C89B3C with Dark Text
              Expanded(
                child: _colorStatBox(
                  bg: AppTheme.primaryGold,
                  iconColor: AppTheme.secondaryNavy,
                  textColor: AppTheme.textDark,
                  icon: Icons.groups_rounded,
                  number: num.tryParse(_homeStats['martyrs_families_supported']?.toString() ?? '') ??
                      num.tryParse(_homeStats['families_supported']?.toString() ?? '') ??
                      40,
                  label: 'Martyrs’ Families\nSupported',
                ),
              ),
              const SizedBox(width: 10),
              // Block 2: Navy #0A1F44 with White Text & Gold Icon
              Expanded(
                child: _colorStatBox(
                  bg: AppTheme.secondaryNavy,
                  iconColor: AppTheme.primaryGold,
                  textColor: Colors.white,
                  icon: Icons.school_rounded,
                  number: num.tryParse(_homeStats['martyrs_children_educated']?.toString() ?? '') ??
                      num.tryParse(_homeStats['children_educated']?.toString() ?? '') ??
                      120,
                  label: 'Martyrs’ Children\nEducated',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Block 3: Navy #0A1F44 with White Text & Gold Icon
              Expanded(
                child: _colorStatBox(
                  bg: AppTheme.secondaryNavy,
                  iconColor: AppTheme.primaryGold,
                  textColor: Colors.white,
                  icon: Icons.currency_rupee_rounded,
                  number: num.tryParse(_homeStats['total_members']?.toString() ?? '') ?? 85,
                  label: 'Registered Active\nMembers',
                ),
              ),
              const SizedBox(width: 10),
              // Block 4: Gold #C89B3C with Dark Text
              Expanded(
                child: _colorStatBox(
                  bg: AppTheme.primaryGold,
                  iconColor: AppTheme.secondaryNavy,
                  textColor: AppTheme.textDark,
                  icon: Icons.volunteer_activism_rounded,
                  number: num.tryParse(_homeStats['relief_welfare_interventions']?.toString() ?? '') ??
                      num.tryParse(_homeStats['relief_interventions']?.toString() ?? '') ??
                      300,
                  label: 'Relief & Welfare\nInterventions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: AppTheme.textDark,
                  ),
                  onPressed: () => widget.onNavigateTab(2),
                  child: const Text('Donate Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryNavy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
                    );
                  },
                  child: const Text('Join Us Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorStatBox({
    required Color bg,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required num number,
    String prefix = '',
    String suffix = '+',
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 6),
          AnimatedStatCounter(
            target: number,
            prefix: prefix,
            suffix: suffix,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor.withAlpha(210),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Featured Campaigns matching donation.php ---
  Widget _buildWebsiteDonationCampaigns() {
    return Container(
      color: AppTheme.warmCreamLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleTag('DONATION'),
          const SizedBox(height: 6),

          const Text(
            'Your Contribution Brings Hope to Martyrs’ Families',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          const Text(
            'Every donation helps us support the families of our brave martyrs with dignity, care, and long-term security.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),

          if (_homeCampaigns.isNotEmpty)
            ..._homeCampaigns.map((c) {
              final title = c['title']?.toString() ?? 'Welfare Campaign';
              final tag = c['category']?.toString() ?? 'Welfare';
              final raisedNum = double.tryParse(c['raised_amount']?.toString() ?? '0') ?? 0;
              final goalNum = double.tryParse(c['goal_amount']?.toString() ?? '100000') ?? 100000;
              final pct = goalNum > 0 ? (raisedNum / goalNum).clamp(0.0, 1.0) : 0.0;
              final img = c['image_url']?.toString() ?? AppConstants.armyHero;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _campaignCard(
                  title: title,
                  raised: '₹${NumberFormat('#,##,###').format(raisedNum.toInt())}',
                  goal: '₹${NumberFormat('#,##,###').format(goalNum.toInt())}',
                  percent: pct,
                  tag: tag,
                  image: img,
                ),
              );
            })
          else ...[
            _campaignCard(
              title: 'Martyr Family Financial Aid',
              raised: '₹8,00,000',
              goal: '₹10,00,000',
              percent: 0.85,
              tag: 'Family Aid',
              image: AppConstants.armyHero,
            ),
            const SizedBox(height: 14),
            _campaignCard(
              title: 'Education for Martyrs’ Children',
              raised: '₹3,75,000',
              goal: '₹5,00,000',
              percent: 0.75,
              tag: 'Education',
              image: AppConstants.educationChild,
            ),
            const SizedBox(height: 14),
            _campaignCard(
              title: 'Medical Care & Health Support',
              raised: '₹4,50,000',
              goal: '₹6,00,000',
              percent: 0.75,
              tag: 'Healthcare',
              image: AppConstants.healthSupport,
            ),
          ],
        ],
      ),
    );
  }

  Widget _campaignCard({
    required String title,
    required String raised,
    required String goal,
    required double percent,
    required String tag,
    required String image,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              image.startsWith('http')
                  ? Image.network(
                      image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        AppConstants.armyHero,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 150,
                          color: AppTheme.secondaryNavy,
                        ),
                      ),
                    )
                  : Image.asset(
                      image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        AppConstants.armyHero,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 150,
                          color: AppTheme.secondaryNavy,
                        ),
                      ),
                    ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: percent),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return LinearProgressIndicator(
                        value: val,
                        minHeight: 8,
                        backgroundColor: AppTheme.cardBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Raised: $raised (${(percent * 100).toInt()}%)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGoldDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Goal: $goal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: AppTheme.textDark,
                    ),
                    onPressed: () => widget.onNavigateTab(2),
                    child: const Text('Donate Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Bank Details matching website donation.php ---
  Widget _buildWebsiteBankDetails(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance, color: AppTheme.secondaryNavy),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Direct Bank Transfer / UPI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Transfer directly using NEFT, IMPS or UPI to our official bank account:',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Divider(height: 20),

          _bankRowCopy(context, 'Account Name', AppConstants.bankAccountName),
          _bankRowCopy(context, 'Bank Name', AppConstants.bankName),
          _bankRowCopy(context, 'Account No.', AppConstants.bankAccountNumber, isCopy: true),
          _bankRowCopy(context, 'IFSC Code', AppConstants.bankIfsc, isCopy: true),
          _bankRowCopy(context, 'Branch', AppConstants.bankBranch),
          _bankRowCopy(context, 'UPI ID', AppConstants.upiId, isCopy: true),
        ],
      ),
    );
  }

  Widget _bankRowCopy(BuildContext context, String label, String val, {bool isCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    val,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCopy) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: val));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy, size: 14, color: AppTheme.primaryGoldDark),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Footer Section matching website footer.php ---
  Widget _buildWebsiteFooter(BuildContext context, AppRepository repo) {
    return Container(
      color: AppTheme.secondaryNavy,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  AppConstants.logoPath,
                  height: 28,
                  errorBuilder: (_, _, _) => const Icon(Icons.shield),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Shaheed Foundation India',
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _footerContact(Icons.location_on, AppConstants.address),
          _footerContact(Icons.phone, AppConstants.phoneDisplay),
          _footerContact(Icons.email, AppConstants.email),

          const Divider(color: Colors.white24, height: 24),

          const Text(
            'Business Hours',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monday - Friday: 09:00 am - 07:00 pm\nSaturday: 09:00 am - 12:00 pm | Sunday: Closed',
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
          ),

          const Divider(color: Colors.white24, height: 24),

          // Quick Navigation Links
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _footerLink(context, 'About Us', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }),
              _footerLink(context, 'Our Services', () => widget.onNavigateTab(1)),
              _footerLink(context, 'Our Documents', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              }),
              _footerLink(context, 'Gallery', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
              }),
              _footerLink(context, 'Member Apply', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberApplyScreen()));
              }),
              _footerLink(context, 'Contact Us', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
              }),
            ],
          ),

          const SizedBox(height: 18),
          const Text(
            '© 2026 Shaheed Foundation India. All Rights Reserved.\nRegistered Section 8 Non-Profit Company (Govt. of India)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _footerContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }


  // --- Quick Access Mobile Feature Dock ---
  Widget _buildQuickFeatureDock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.bolt, color: AppTheme.primaryGoldDark, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'QUICK SERVICES & TOOLS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.secondaryNavy,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => MainShell.openDrawer(),
                child: const Text(
                  'More Tools >',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 115,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _dockCard(
                context,
                title: 'Services',
                subtitle: 'Support & Welfare',
                icon: Icons.handshake_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => widget.onNavigateTab(1),
              ),
              _dockCard(
                context,
                title: 'Donate',
                subtitle: '80G Tax Benefit',
                icon: Icons.favorite_rounded,
                color: AppTheme.primaryGoldDark,
                iconBg: AppTheme.primaryGold.withAlpha(25),
                onTap: () => widget.onNavigateTab(2),
              ),
              _dockCard(
                context,
                title: 'Members',
                subtitle: 'Portal & Verify',
                icon: Icons.badge_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => widget.onNavigateTab(3),
              ),
              _dockCard(
                context,
                title: 'Our Documents',
                subtitle: '80G & Certifications',
                icon: Icons.description_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                ),
              ),
              _dockCard(
                context,
                title: 'Gallery',
                subtitle: 'Drives & Events',
                icon: Icons.photo_library_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryScreen()),
                ),
              ),
              _dockCard(
                context,
                title: 'Impact Stories',
                subtitle: 'Veer Nari testimonials',
                icon: Icons.military_tech_rounded,
                color: AppTheme.primaryGoldDark,
                iconBg: AppTheme.primaryGold.withAlpha(25),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImpactStoriesScreen()),
                ),
              ),
              _dockCard(
                context,
                title: 'About Us',
                subtitle: 'Leadership & Trust',
                icon: Icons.info_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              _dockCard(
                context,
                title: 'Join Us',
                subtitle: 'Become a Member',
                icon: Icons.person_add_alt_1_rounded,
                color: AppTheme.secondaryNavy,
                iconBg: AppTheme.secondaryNavy.withAlpha(15),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dockCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black.withAlpha(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Beneficiary Testimonials Section (from testimonial.html) ---
  Widget _buildWebsiteTestimonialsSection(BuildContext context, AppRepository repo) {
    final list = _approvedTestimonials.isNotEmpty ? _approvedTestimonials : repo.testimonials;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 24, height: 3, color: AppTheme.primaryGold),
              const SizedBox(width: 8),
              const Text(
                'TESTIMONIALS & IMPACT',
                style: TextStyle(
                  color: AppTheme.primaryGoldDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'What Families Say About Us',
            style: TextStyle(
              color: AppTheme.secondaryNavy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Real stories of resilience, scholarships, and rehabilitation from the families of our brave martyrs.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),

          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rate_review_outlined, color: AppTheme.primaryGoldDark, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Voices of Resilience & Dignity',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.secondaryNavy),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Beneficiary stories and citizen testimonials appear here following verification and approval by the Foundation Admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _openReviewSubmissionModal(context),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Share Your Story / Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: AppTheme.secondaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Horizontal scroll of verified, approved testimonial cards
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final t = list[i];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.secondaryNavy,
                              child: ClipOval(
                                child: Image.asset(
                                  t.imagePath,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    t.location,
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.format_quote_rounded, color: AppTheme.primaryGold, size: 22),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${t.quote}"',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4B5563),
                            height: 1.35,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                t.impactBadge,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF137333)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: Color(0xFF137333)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImpactStoriesScreen()),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Read All Stories'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryNavy,
                    side: const BorderSide(color: AppTheme.secondaryNavy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _openReviewSubmissionModal(context),
                  icon: const Icon(Icons.rate_review, size: 16),
                  label: const Text('Submit Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: AppTheme.secondaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openReviewSubmissionModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final progCtrl = TextEditingController();
    final quoteCtrl = TextEditingController();
    int rating = 5;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.rate_review, color: AppTheme.primaryGoldDark, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Your Story / Review',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                            ),
                            Text(
                              'Subject to review & approval by Foundation Admin',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFFF57F17), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To maintain integrity, citizen & beneficiary reviews only appear publicly after being verified and approved by the admin.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF5D4037), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: roleCtrl,
                          decoration: InputDecoration(
                            labelText: 'Your Role / Relation',
                            hintText: 'e.g. Beneficiary, Veer Nari',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: locCtrl,
                          decoration: InputDecoration(
                            labelText: 'City & State',
                            hintText: 'e.g. Rohtak, Haryana',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: progCtrl,
                    decoration: InputDecoration(
                      labelText: 'Program or Cause Supported',
                      hintText: 'e.g. Education Aid, Elderly Healthcare',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ...List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFFFB300),
                            size: 26,
                          ),
                          onPressed: () => setModalState(() => rating = index + 1),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quoteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Your Story / Review Quote *',
                      hintText: 'Describe how the foundation supported you or how you participated...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final quote = quoteCtrl.text.trim();
                              if (name.isEmpty || quote.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your name and story.')),
                                );
                                return;
                              }
                              setModalState(() => isSubmitting = true);
                              final res = await ApiService().submitTestimonial(
                                data: {
                                  'name': name,
                                  'relation': roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : 'Beneficiary',
                                  'location': locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : 'India',
                                  'program': progCtrl.text.trim().isNotEmpty ? progCtrl.text.trim() : 'Welfare & Relief',
                                  'quote': quote,
                                  'rating': rating,
                                  'impact_badge': 'Verified Beneficiary',
                                },
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.message ?? 'Review submitted! It will appear once approved by admin.'),
                                    backgroundColor: AppTheme.secondaryNavy,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      icon: isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(isSubmitting ? 'Submitting...' : 'Submit for Admin Approval'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.secondaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _sectionTitleTag(String title) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 2,
          color: AppTheme.primaryGold,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGoldDark,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
