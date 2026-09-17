import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/app_repository.dart';
import '../../models/service_program.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../donation/donation_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../team/our_team_screen.dart';
import 'service_detail_screen.dart';
import '../main_shell.dart';

class ServicesScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const ServicesScreen({super.key, this.onNavigateTab});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final repo = AppRepository();
  String _selectedCategory = 'all';

  ServiceType _getServiceType(String id) {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open Menu',
                onPressed: () => MainShell.openDrawer(),
              ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                AppConstants.logoPath,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.shield,
                  size: 24,
                  color: AppTheme.secondaryNavy,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Services'),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Horizontal Gold Sub-Navbar Chips (Desktop only - mobile uses BottomNav/Drawer)
          if (Responsive.isDesktop(context))
            _buildNavbar(context),

          // 2. Page Header Banner (Breadcrumb style like website)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.isMobile(context) ? 16 : 22,
              horizontal: Responsive.isMobile(context) ? 16 : 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryGold, width: 3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Our Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.isMobile(context) ? 20 : 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                // Clickable Breadcrumb
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(0);
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.home_outlined, size: 14, color: AppTheme.primaryGold),
                            SizedBox(width: 4),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      ' /  Services',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          ResponsiveContainer(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isMobile(context) ? 12 : 20,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Section Title Tag
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 3,
                        color: AppTheme.primaryGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SERVICES',
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
                    'How We Support Martyrs’ Families',
                    style: TextStyle(
                      color: AppTheme.secondaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We stand beside the families of our brave martyrs by providing financial, educational, medical, and emotional support to help them live with dignity and security.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Service Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All Services', 'all'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Financial Support', 'financial'),
                        const SizedBox(width: 8),
                        _buildCategoryChip("Children's Education", 'education'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Medical & Healthcare', 'medical'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Employment & Skills', 'employment'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Program Cards (Filtered)
                  ...repo.services
                      .where((p) {
                        if (_selectedCategory == 'all') return true;
                        if (_selectedCategory == 'medical') return p.id == 'medical' || p.id == 'disability';
                        return p.id == _selectedCategory;
                      })
                      .map((program) => _buildProgramCard(program)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryNavy : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.secondaryNavy.withAlpha(30), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      color: AppTheme.primaryGold,
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _navChip('Home', onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(0);
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }),
          _navChip('About', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
          _navChip('Our Team', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OurTeamScreen()));
          }),
          _navChip('Services', isActive: true, onTap: () {}),
          _navChip('Donation', onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(2);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationScreen()));
            }
          }),
          _navChip('Our Documents', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()));
          }),
          _navChip('Gallery & Events', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
          }),
          _navChip('Join Us', isButton: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberApplyScreen()));
          }),
          _navChip('Contact', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
          }),
        ],
      ),
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
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isButton
                    ? Colors.white
                    : (isActive ? AppTheme.secondaryNavy : Colors.black87),
                fontWeight: isActive || isButton ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCard(ServiceProgram program) {
    final sType = _getServiceType(program.id);

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
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Image Header
            Stack(
              children: [
                Image.asset(
                  program.imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    color: AppTheme.secondaryNavy,
                    child: Center(
                      child: Icon(program.icon, size: 48, color: Colors.white38),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryNavy,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(program.icon, color: AppTheme.primaryGold, size: 22),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'What We Provide:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...program.benefits.take(3).map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppTheme.primaryGold, size: 16),
                            const SizedBox(width: 8),
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
                  const SizedBox(height: 14),
                  // Bottom Actions: Full details button and apply button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondaryNavy,
                            side: const BorderSide(color: AppTheme.secondaryNavy),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text(
                            'Full Details',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
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
                          icon: const Icon(Icons.touch_app, size: 16),
                          label: const Text(
                            'Apply Support',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
