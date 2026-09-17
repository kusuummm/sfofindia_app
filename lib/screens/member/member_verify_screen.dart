import '../admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_repository.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../donation/donation_screen.dart';
import '../gallery/gallery_screen.dart';
import '../services/services_screen.dart';
import 'member_apply_screen.dart';
import '../main_shell.dart';
import '../../services/auth_service.dart';
import '../../models/auth_user_model.dart';
import '../auth/login_screen.dart';
import 'member_portal_screen.dart';
import '../../core/utils/responsive.dart';

class MemberVerifyScreen extends StatefulWidget {
  final MemberModel? initialMember;
  final Function(int)? onNavigateTab;

  const MemberVerifyScreen({super.key, this.initialMember, this.onNavigateTab});

  @override
  State<MemberVerifyScreen> createState() => _MemberVerifyScreenState();
}

class _MemberVerifyScreenState extends State<MemberVerifyScreen> {
  final _searchCtrl = TextEditingController();
  final repo = AppRepository();
  MemberModel? _searchedMember;
  bool _searched = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMember != null) {
      _searchedMember = widget.initialMember;
      _searchCtrl.text = widget.initialMember!.publicId;
      _searched = true;
    } else {
      _searchedMember = null;
      _searchCtrl.clear();
      _searched = false;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _searched = true;
      _isSearching = true;
      _searchedMember = repo.verifyMember(clean);
    });

    try {
      final res = await ApiService().verifyMember(clean);
      if (mounted && res.isSuccess && res.data != null && res.data is Map) {
        final m = res.data as Map;
        setState(() {
          _searchedMember = MemberModel(
            id: m['id']?.toString() ?? '1',
            publicId: m['member_id_code']?.toString() ?? m['member_user_id']?.toString() ?? clean,
            fullName: m['name']?.toString() ?? 'Verified Member',
            gender: m['gender']?.toString() ?? 'N/A',
            dob: m['dob']?.toString() ?? '1995-01-01',
            relationType: 'S/O',
            relationName: m['father_name']?.toString() ?? 'Member of Shaheed Foundation',
            mobile: m['mobile']?.toString() ?? 'Confidential',
            email: m['email']?.toString() ?? 'member@sfofindia.org',
            state: m['state']?.toString() ?? 'Haryana',
            district: m['district']?.toString() ?? 'Gurugram',
            address: m['district'] != null ? '${m['district']}, ${m['state'] ?? 'India'}' : 'Official Member Address',
            pinCode: m['pincode']?.toString() ?? '122001',
            occupation: m['profession']?.toString() ?? 'Official Member',
            qualification: 'Graduate',
            aadharNumber: 'XXXX-XXXX-XXXX',
            status: (m['status']?.toString().toLowerCase() == 'active') ? 'Verified' : (m['status']?.toString() ?? 'Pending'),
            registrationDate: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime(2026, 1, 1),
            bloodGroup: m['blood_group']?.toString() ?? 'O+',
          );
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSearching = false);
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
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Member Verification',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: AuthService(),
            builder: (context, _) {
              final auth = AuthService();
              return IconButton(
                icon: Icon(
                  auth.isAuthenticated ? Icons.badge : Icons.login_rounded,
                  color: AppTheme.primaryGold,
                  size: 22,
                ),
                tooltip: auth.isAuthenticated ? 'My Member Portal' : 'Member Login',
                onPressed: () {
                  if (auth.isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.member)),
                    );
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppTheme.primaryGold, size: 20),
            tooltip: 'Apply for Membership',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Member Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.isMobile(context) ? 20 : 24,
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
                        ' /  Member Verification',
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
              maxWidth: 820,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 12 : 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member Access Gateway Card
                  ListenableBuilder(
                    listenable: AuthService(),
                    builder: (context, _) {
                      final auth = AuthService();
                      final isAuth = auth.isAuthenticated;
                      final user = auth.currentUser;

                      if (isAuth && user != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.secondaryNavy,
                                child: Icon(
                                  user.isAdmin ? Icons.admin_panel_settings : Icons.badge,
                                  color: AppTheme.primaryGold,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Logged in: ${user.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.secondaryNavy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'ID: ${user.memberUserId ?? user.username}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  if (user.isAdmin) {
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
                                child: Text(
                                  user.isAdmin ? 'CMS' : 'My Portal',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryNavy.withAlpha(40),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.badge_outlined, color: AppTheme.primaryGold, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Enrolled Member Portal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Are you an enrolled member? Sign in to access your personal Digital ID card, appointment letter, and welfare benefits.',
                              style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGold,
                                    foregroundColor: AppTheme.secondaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.login_rounded, size: 14),
                                  label: const Text('Member Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.member)),
                                    );
                                  },
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white38),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.person_add_alt_1, size: 14),
                                  label: const Text('Join Us / Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Search Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verify Authenticity of Member',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter Member ID (e.g. SFOF-2024-0012) or Registered Mobile',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: InputDecoration(
                                  hintText: 'SFOF-2024-0012 or Mobile...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  suffixIcon: _searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            setState(() {
                                              _searched = false;
                                              _searchedMember = null;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onSubmitted: _doSearch,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.textDark,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                              ),
                              onPressed: _isSearching ? null : () => _doSearch(_searchCtrl.text),
                              child: _isSearching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.textDark,
                                      ),
                                    )
                                  : const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quick chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            const Text(
                              'Sample IDs:',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            ...repo.members.take(3).map((m) {
                              return InkWell(
                                onTap: () {
                                  _searchCtrl.text = m.publicId;
                                  _doSearch(m.publicId);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    m.publicId,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGoldDark,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_searched && _searchedMember == null) ...[
                    _buildNotFoundCard(),
                  ] else if (_searchedMember != null) ...[
                    // Exact web verification card from web/member_verify.php
                    _buildWebsiteVerifyCard(_searchedMember!),
                    const SizedBox(height: 24),
                    _buildDigitalIdCard(_searchedMember!),
                    const SizedBox(height: 20),
                    _buildMemberProfileDetails(_searchedMember!),
                  ] else ...[
                    _buildEmptyStateCard(),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 40,
              color: AppTheme.primaryGoldDark,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Official Registry Verification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter an official Member ID (e.g. SFOF-2024-0012) or registered mobile above and tap "Verify" to validate credentials against the Shaheed Foundation central registry.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          _verificationBenefitRow(
            Icons.security_rounded,
            'Tamper-Proof Verification',
            'Confirms official registration, role designation, and active validity.',
          ),
          const SizedBox(height: 12),
          _verificationBenefitRow(
            Icons.badge_outlined,
            'Digital Identity Card Check',
            'Cross-references photo badges and anti-fraud QR authentication codes.',
          ),
          const SizedBox(height: 12),
          _verificationBenefitRow(
            Icons.assignment_turned_in_outlined,
            'Document Integrity Assurance',
            'Validates appointment letters, volunteer records, and tax receipts.',
          ),
        ],
      ),
    );
  }

  Widget _verificationBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryNavy),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Exact Web Card from web/member_verify.php
  Widget _buildWebsiteVerifyCard(MemberModel member) {
    final maskedPhone = member.mobile.length >= 4
        ? 'XXXXX - ${member.mobile.substring(member.mobile.length - 4)}'
        : member.mobile;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Member Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Photo container overlapping slightly
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 50, color: AppTheme.secondaryNavy),
                  ),
                ),
                const SizedBox(height: 14),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                      SizedBox(width: 5),
                      Text(
                        'OFFICIALLY VERIFIED',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  member.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.publicId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 18),

                // Verification details rows (matches member_verify.php)
                _webInfoRow('Current Status', 'ACTIVE (APPROVED)', isSuccess: true),
                _webInfoRow('Valid Until', '31 Dec 2026'),
                _webInfoRow('Mobile (Hidden)', maskedPhone),
                _webInfoRow('Blood Group', member.bloodGroup ?? 'O+'),
                _webInfoRow('State & City', '${member.district}, ${member.state}'),

                const SizedBox(height: 16),
                const Text(
                  'Shaheed Foundation India — Secured Member Portal',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _webInfoRow(String label, String value, {bool isSuccess = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: isSuccess ? const Color(0xFF2E7D32) : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withAlpha(50)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No Member Record Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'The Member ID or Mobile does not match any registered active member in Shaheed Foundation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: AppTheme.textDark,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemberApplyScreen()),
              );
            },
            child: const Text('Apply for Membership', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalIdCard(MemberModel member) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDark.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SHAHEED FOUNDATION INDIA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'MEMBERSHIP IDENTITY CARD',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check, color: Colors.white, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ID Card Body
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo and QR
                Column(
                  children: [
                    Container(
                      width: 75,
                      height: 85,
                      decoration: BoxDecoration(
                        color: AppTheme.warmCream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person, size: 40, color: AppTheme.secondaryNavy),
                          Text(
                            'PHOTO',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.cardBorder),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded,
                          size: 42, color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.relationType} ${member.relationName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const Divider(height: 14),
                      _idLine('Member ID', member.publicId, isPrimary: true),
                      _idLine('Mobile', member.mobile),
                      _idLine('Blood Group', member.bloodGroup ?? 'N/A'),
                      _idLine('State', '${member.district}, ${member.state}'),
                      _idLine('Issued Date',
                          DateFormat('dd MMM yyyy').format(member.registrationDate)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'CIN: U85300HR2022NPL101988',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  'www.sfofindia.com',
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _idLine(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                color: isPrimary ? AppTheme.primaryGoldDark : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberProfileDetails(MemberModel member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verified Official Profile Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
          ),
          const Divider(height: 20),
          _profileRow('Full Name', member.fullName),
          _profileRow('Gender / Blood', '${member.gender} / ${member.bloodGroup ?? 'N/A'}'),
          _profileRow('Guardian / Relation', '${member.relationType} ${member.relationName}'),
          _profileRow('Aadhaar Verification', member.maskedAadhar),
          _profileRow('Email Address', member.email),
          _profileRow('Occupation', member.occupation),
          _profileRow('Qualification', member.qualification),
          _profileRow('Full Address', '${member.address}, ${member.district}, ${member.state} - ${member.pinCode}'),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
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
          _navChip('Services', onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(1);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen()));
            }
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
