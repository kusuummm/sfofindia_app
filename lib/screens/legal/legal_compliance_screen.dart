import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_helper.dart';
import '../widgets/document_preview_dialog.dart';

class LegalComplianceScreen extends StatefulWidget {
  final int initialTabIndex;
  const LegalComplianceScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalComplianceScreen> createState() => _LegalComplianceScreenState();
}

class _LegalComplianceScreenState extends State<LegalComplianceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Legal & Compliance'),
        backgroundColor: AppTheme.secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryGold,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms & Conditions'),
            Tab(text: '80G & Legal Status'),
            Tab(text: 'Donation Refund'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacyPolicyTab(),
          _buildTermsTab(),
          _buildLegalStatusTab(),
          _buildRefundPolicyTab(),
        ],
      ),
    );
  }

  // --- TAB 1: PRIVACY POLICY (Play Store Mandate) ---
  Widget _buildPrivacyPolicyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeaderCard(
          icon: Icons.shield_outlined,
          title: 'Official Privacy Policy',
          subtitle: 'Last updated: August 2026 • Compliant with Google Play Store Policies & IT Act 2000',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '1. Overview & Commitment',
          content:
              'Shaheed Foundation of India ("we", "our", or "the Foundation") is a Section 8 licensed non-profit dedicated to the welfare of martyrs\' families and defense veterans. We take your personal privacy very seriously and are committed to protecting all personal information shared through our mobile application and website (sfofindia.com).',
        ),
        _buildSectionCard(
          title: '2. Information We Collect',
          content:
              'We only collect information necessary to fulfill our humanitarian missions and statutory obligations:\n\n'
              '• Identity Details: Name, contact phone number, email address, date of birth, and blood group for member verification and emergency welfare coordination.\n'
              '• Financial & Tax Info: PAN card number and donation amount required under Section 80G of the Income Tax Act for issuing official tax exemption certificates.\n'
              '• Documents & Photos: Profile photos and government identity proofs (uploaded voluntarily by applicants for digital membership identity card generation).',
        ),
        _buildSectionCard(
          title: '3. Device Permissions & Usage',
          content:
              '• Camera & Gallery: Used solely when you choose to take or upload a profile picture or document verification proof for membership registration.\n'
              '• Internet Access: Required to communicate with our secure encrypted server endpoints and verify membership authenticity in real time.\n\n'
              'We never access your contacts, SMS, microphone, or precise background location.',
        ),
        _buildSectionCard(
          title: '4. Data Protection & Non-Commercial Guarantee',
          content:
              '• We NEVER sell, rent, monetize, or trade your personal data to third parties, advertisers, or commercial entities.\n'
              '• All communication with our servers is secured using SSL/TLS encryption.\n'
              '• Sensitive credentials such as passwords are encrypted using one-way bcrypt hashing algorithms.',
        ),
        _buildSectionCard(
          title: '5. User Rights & Account Deletion',
          content:
              'You have the legal right to review, update, or request the permanent deletion of your account, login credentials, and uploaded identity records at any time.\n\n'
              '• In-App Deletion: Go to Member Portal > Security & KYC > Account & Data Deletion.\n'
              '• Web Form: Visit our dedicated deletion form at sfofindia.com/delete-account.\n'
              '• Email Grievance: Email us at privacy@sfofindia.com or info@sfofindia.com.\n\n'
              'Verified account deletion requests are processed by our compliance officer within 7 business days.',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: AppTheme.secondaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('Full Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => UrlHelper.launchWebUrl(AppConstants.privacyPolicyUrl),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => UrlHelper.launchWebUrl(AppConstants.accountDeletionUrl),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Text(
            AppConstants.governmentDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.35),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- TAB 2: TERMS & CONDITIONS ---
  Widget _buildTermsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeaderCard(
          icon: Icons.gavel_rounded,
          title: 'Terms of Use & Membership Charter',
          subtitle: 'Governing membership, donations, and volunteer activities',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '1. Acceptance of Terms',
          content:
              'By accessing or using the Shaheed Foundation of India mobile application, you agree to comply with and be bound by these terms. If you do not agree, please discontinue use of the platform.',
        ),
        _buildSectionCard(
          title: '2. Member Identity & Code of Conduct',
          content:
              '• Official Digital Membership ID cards issued through this application remain the property of the Shaheed Foundation of India.\n'
              '• Members are strictly prohibited from using Foundation credentials for unauthorized personal gain, political solicitation, or fraudulent misrepresentation.\n'
              '• Any misuse results in immediate revocation of membership and potential legal action under applicable Indian laws.',
        ),
        _buildSectionCard(
          title: '3. Intellectual Property',
          content:
              'All logos, emblems, tricolor insignia, documentation formats, and content within this application are protected trademarks and copyrights of the Shaheed Foundation of India.',
        ),
        _buildSectionCard(
          title: '4. Voluntary Participation',
          content:
              'Participation in voluntary welfare drives, blood donation networks, or awareness campaigns is entirely voluntary. The Foundation coordinates community welfare with complete integrity.',
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.secondaryNavy,
            side: const BorderSide(color: AppTheme.secondaryNavy),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Read Full Terms on Website', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => UrlHelper.launchWebUrl('https://sfofindia.com/terms'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- TAB 3: 80G & LEGAL COMPLIANCE ---
  Widget _buildLegalStatusTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeaderCard(
          icon: Icons.verified_user_rounded,
          title: 'Statutory Registrations & 80G Approval',
          subtitle: '100% compliant with Ministry of Corporate Affairs, Income Tax Dept & NITI Aayog',
        ),
        const SizedBox(height: 16),

        _buildComplianceRow('Legal Entity Type', 'Section 8 Non-Profit (Companies Act, 2013)'),
        _buildComplianceRow('Corporate ID (CIN)', AppConstants.regCertNumber),
        _buildComplianceRow('PAN Number', AppConstants.panNumber),
        _buildComplianceRow('Section 80G Approval', 'AAXCS2334MF20241 (50% Tax Deduction)'),
        _buildComplianceRow('Section 12A Registration', 'AAXCS2334ME20241 (Tax Exemption)'),
        _buildComplianceRow('NITI Aayog NGO Darpan', 'Verified & Registered Entity'),
        _buildComplianceRow('Registered Office', AppConstants.address),

        const SizedBox(height: 20),
        const Text(
          'Official Document Previews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),

        _buildDocActionTile(
          icon: Icons.description,
          title: 'Section 80G Income Tax Approval',
          subtitle: 'URN: AAXCS2334MF20241 • Tax deduction certificate',
          onTap: () {
            DocumentPreviewDialog.show(
              context,
              type: DocumentType.taxReceipt80G,
              memberName: 'Shaheed Foundation of India',
              memberId: '80G-CERT-2024',
              donationAmount: 0,
              receiptNumber: 'AAXCS2334MF20241',
            );
          },
        ),
        _buildDocActionTile(
          icon: Icons.credit_card,
          title: 'Official Foundation PAN Card',
          subtitle: 'PAN: AAECS8948K • Permanent Account Number',
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(AppConstants.panCardPath, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 12),
                      const Text('Shaheed Foundation PAN: AAECS8948K', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- TAB 4: DONATION REFUND POLICY ---
  Widget _buildRefundPolicyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeaderCard(
          icon: Icons.currency_rupee_rounded,
          title: 'Donation & Refund Policy',
          subtitle: 'Transparent, accountable financial policies for all contributions',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '1. Non-Profit Donations Policy',
          content:
              'Shaheed Foundation of India receives contributions that are immediately allocated to active welfare programs for martyrs\' families, scholarships for martyr children, and emergency medical grants. As such, donations are generally non-refundable once disbursed.',
        ),
        _buildSectionCard(
          title: '2. Duplicate or Erroneous Transactions',
          content:
              'If a technical error or server glitch causes a duplicate deduction, or if an incorrect donation amount was charged:\n\n'
              '• Please notify our accounts desk within 48 hours of transaction completion.\n'
              '• Email us at accounts@sfofindia.com or info@sfofindia.com with your transaction ID, payment screenshot, and bank reference.\n'
              '• Upon verification, duplicate amounts are refunded directly to the original payment source within 7-10 business days.',
        ),
        _buildSectionCard(
          title: '3. Section 80G Tax Exemption Receipts',
          content:
              'All donors are issued valid digital 80G tax exemption receipts containing our official URN. Please ensure your PAN number is correctly provided during contribution to facilitate seamless Income Tax return filing.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper Widgets
  Widget _buildHeaderCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Icon(icon, color: const Color(0xFFFBBF24), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEEF2FF),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}
