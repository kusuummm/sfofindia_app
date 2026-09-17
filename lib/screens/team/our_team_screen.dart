import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../services/api_service.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../donation/donation_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../services/services_screen.dart';
import '../main_shell.dart';

class OurTeamScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const OurTeamScreen({super.key, this.onNavigateTab});

  @override
  State<OurTeamScreen> createState() => _OurTeamScreenState();
}

class _OurTeamScreenState extends State<OurTeamScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'leadership', 'members'
  List<Map<String, dynamic>> _dynamicMembers = [];

  // Core Leadership & Advisory Council matching website team.php
  static const List<Map<String, String>> _coreLeadership = [
    {
      'name': 'Col. S. K. Verma (Retd.)',
      'role': 'Advisory Council Head',
      'badge': 'Advisory Board',
      'icon': 'shield',
    },
    {
      'name': 'Adv. Rajesh Sharma',
      'role': 'Legal Advisor & Trustee',
      'badge': 'Legal Council',
      'icon': 'gavel',
    },
    {
      'name': 'Dr. Ananya Mishra',
      'role': 'Medical & Health Coordinator',
      'badge': 'Healthcare Head',
      'icon': 'medical_services',
    },
    {
      'name': 'Vikramaditya Singh',
      'role': 'Youth Volunteer Lead',
      'badge': 'Youth Wing',
      'icon': 'groups',
    },
    {
      'name': 'Pooja Deshmukh',
      'role': 'Family Outreach Coordinator',
      'badge': 'Family Welfare',
      'icon': 'volunteer_activism',
    },
    {
      'name': 'Sanjay Patel',
      'role': 'Program & Logistics Director',
      'badge': 'Logistics & Ops',
      'icon': 'local_shipping',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadActiveMembers();
  }

  Future<void> _loadActiveMembers() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getMembers(status: 'active');
      if (res.isSuccess && res.data is List) {
        setState(() {
          _dynamicMembers = List<Map<String, dynamic>>.from(res.data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
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
            const Text('Our Team'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveMembers,
        color: AppTheme.primaryGold,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 1. Desktop Sub-Navbar Chips
            if (Responsive.isDesktop(context)) _buildDesktopNavbar(context),

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
                    'Our Team',
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
                        ' /  Our Team',
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
                horizontal: Responsive.isMobile(context) ? 14 : 24,
                vertical: 20,
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
                        'OUR TEAM',
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
                    "Dedicated Members Standing with Our Nation's Heroes",
                    style: TextStyle(
                      color: AppTheme.secondaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Together with volunteers, donors, and verified members across India, we work tirelessly for the welfare of martyrs' families.",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Apply for Membership CTA banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGold.withAlpha(40),
                          AppTheme.primaryGold.withAlpha(15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.how_to_reg, color: AppTheme.secondaryNavy, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Want to join our nationwide team?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: AppTheme.secondaryNavy,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Apply for membership & support veer naris directly.',
                                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
                            );
                          },
                          child: const Text(
                            'Join Us',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Segmented Chips (All, Leadership, Verified Members)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Team', 'all', _coreLeadership.length + _dynamicMembers.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('Advisory & Leadership', 'leadership', _coreLeadership.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('Verified Members', 'members', _dynamicMembers.length),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content based on filter
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
                    )
                  else ...[
                    // 1. Leadership Section
                    if (_selectedFilter == 'all' || _selectedFilter == 'leadership') ...[
                      Row(
                        children: const [
                          Icon(Icons.security, size: 18, color: AppTheme.secondaryNavy),
                          SizedBox(width: 6),
                          Text(
                            'Advisory Council & Executive Board',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 195,
                            ),
                            itemCount: _coreLeadership.length,
                            itemBuilder: (context, index) {
                              return _buildLeadershipCard(_coreLeadership[index]);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 2. Verified Dynamic Members Section
                    if (_selectedFilter == 'all' || _selectedFilter == 'members') ...[
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 18, color: Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          Text(
                            'Active & Verified Members (${_dynamicMembers.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_dynamicMembers.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.people_outline, size: 40, color: Colors.black26),
                              SizedBox(height: 8),
                              Text(
                                'No verified members loaded yet.',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Newly approved members from database will appear here.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 205,
                              ),
                              itemCount: _dynamicMembers.length,
                              itemBuilder: (context, index) {
                                return _buildDynamicMemberCard(_dynamicMembers[index], index);
                              },
                            );
                          },
                        ),
                    ],
                  ],

                  const SizedBox(height: 30),

                  // Bottom Call to Action
                  _buildBottomCtaCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
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
              ? [BoxShadow(color: AppTheme.secondaryNavy.withAlpha(40), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGold : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.secondaryNavy : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadershipCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), AppTheme.secondaryNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryGold, width: 2),
                ),
                child: Center(
                  child: Text(
                    _getInitials(item['name']!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['name']!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['role']!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primaryGoldDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.warmCreamLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['badge']!,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMemberCard(Map<String, dynamic> member, int index) {
    final name = (member['name'] ?? member['member_name'] ?? 'Member').toString();
    final rawAuth = (member['authority'] ?? '').toString().trim();
    final profession = (member['profession'] ?? '').toString().trim();
    final city = (member['city'] ?? member['district'] ?? '').toString().trim();
    final state = (member['state'] ?? '').toString().trim();
    final photo = (member['photo'] ?? '').toString().trim();

    String role = 'Active Member';
    if (rawAuth.isNotEmpty && rawAuth.toLowerCase() != 'mambar' && rawAuth.toLowerCase() != 'member') {
      role = rawAuth;
    } else if (profession.isNotEmpty) {
      role = profession;
    }

    String location = '';
    if (city.isNotEmpty && state.isNotEmpty) {
      location = '$city, $state';
    } else if (city.isNotEmpty) {
      location = city;
    } else if (state.isNotEmpty) {
      location = state;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: photo.isNotEmpty && photo.startsWith('http')
                    ? Image.network(
                        photo,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _fallbackAvatar(name, index),
                      )
                    : _fallbackAvatar(name, index),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primaryGoldDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (location.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Verified Member',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(String name, int index) {
    final colors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF0F766E),
      const Color(0xFFB45309),
      const Color(0xFF6D28D9),
      const Color(0xFFBE123C),
    ];
    final color = colors[index % colors.length];

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final clean = name.replaceAll(RegExp(r'^(Col\.|Adv\.|Dr\.|Mr\.|Mrs\.|Ms\.)\s*', caseSensitive: false), '').trim();
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.isNotEmpty ? clean.substring(0, 1).toUpperCase() : 'M';
  }

  Widget _buildBottomCtaCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryNavy.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.people_alt, size: 36, color: AppTheme.primaryGold),
          const SizedBox(height: 10),
          const Text(
            'Join the Foundation Family',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Become a lifetime or annual member today and help us provide immediate aid, scholarships, and rehabilitation to martyrs’ dependents across India.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: AppTheme.secondaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text(
              'Apply For Membership',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavbar(BuildContext context) {
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
          _navChip('Our Team', isActive: true, onTap: () {}),
          _navChip('Services', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen()));
          }),
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
}
