import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/app_repository.dart';
import '../../models/donation_model.dart';
import '../../services/api_service.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../services/services_screen.dart';
import '../main_shell.dart';

class DonationScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DonationScreen({super.key, this.onNavigateTab});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _customAmountCtrl = TextEditingController();

  int _selectedAmount = 1000;
  bool _isCustom = false;
  bool _agreedToTerms = true;
  String _selectedPaymentMethod = 'UPI'; // 'UPI' or 'Bank'
  List<Map<String, dynamic>> _dynamicCampaigns = [];
  int? _selectedCampaignId;
  bool _isSubmitting = false;

  final List<int> _presetAmounts = [500, 1000, 2500, 5000];

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    try {
      final res = await ApiService().getCampaigns();
      if (mounted && res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _dynamicCampaigns = res.data!;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _panCtrl.dispose();
    _customAmountCtrl.dispose();
    super.dispose();
  }

  double get _currentAmount {
    if (_isCustom) {
      return double.tryParse(_customAmountCtrl.text) ?? 0.0;
    }
    return _selectedAmount.toDouble();
  }

  String get _impactMessage {
    final amt = _currentAmount;
    if (amt >= 5000) {
      return '✨ Sponsors a semester’s complete education & books for a martyr’s child.';
    } else if (amt >= 2500) {
      return '✨ Covers 2 months of chronic healthcare & medicines for elderly martyr parents.';
    } else if (amt >= 1000) {
      return '✨ Supplies school bag, uniforms, notebooks & stationery for 1 student.';
    } else if (amt >= 500) {
      return '✨ Provides nutritious monthly ration supplements for a dependent family.';
    }
    return '✨ Every single rupee honors our fallen heroes and supports their families.';
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a valid donation amount')),
      );
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the donation terms & 80G declaration')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = AppRepository();
    String? backendReceipt;
    String? backendTxn;

    try {
      final res = await ApiService().createDonation(data: {
        'donor_name': _nameCtrl.text.trim(),
        'donor_email': _emailCtrl.text.trim(),
        'donor_phone': _phoneCtrl.text.trim(),
        'amount': _currentAmount,
        'payment_method': _selectedPaymentMethod,
        'pan_number': _panCtrl.text.trim().isEmpty ? null : _panCtrl.text.trim().toUpperCase(),
        'campaign_id': _selectedCampaignId,
      });

      if (res.isSuccess && res.data != null) {
        if (res.data is Map) {
          final map = res.data as Map;
          backendReceipt = map['receipt_no']?.toString();
          backendTxn = map['payment_id']?.toString();
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    final donation = repo.recordDonation(
      donorName: _nameCtrl.text.trim(),
      donorEmail: _emailCtrl.text.trim(),
      donorPhone: _phoneCtrl.text.trim(),
      amount: _currentAmount,
      paymentMethod: _selectedPaymentMethod,
      panNumber: _panCtrl.text.trim().isEmpty ? null : _panCtrl.text.trim().toUpperCase(),
      receiptNumber: backendReceipt,
      transactionRef: backendTxn,
    );

    if (mounted) {
      _showReceiptDialog(donation);
    }
  }

  void _showReceiptDialog(DonationModel donation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppTheme.primaryGoldDark, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Official Donation Receipt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const Text(
                  'Shaheed Foundation (Govt. Registered Sec 8 NGO)',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const Divider(height: 24),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGold.withAlpha(60)),
                  ),
                  child: Column(
                    children: [
                      _receiptRow('Receipt No.', donation.receiptNumber ?? 'N/A'),
                      _receiptRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(donation.date)),
                      _receiptRow('Donor Name', donation.donorName),
                      _receiptRow('Email', donation.donorEmail),
                      _receiptRow('Amount Paid', '₹${NumberFormat('#,##,###').format(donation.amount)}', isBold: true),
                      _receiptRow('Payment Method', donation.paymentMethod),
                      if (donation.panNumber != null) _receiptRow('PAN Number', donation.panNumber!),
                      _receiptRow('Transaction ID', donation.transactionRef ?? 'N/A'),
                      const Divider(height: 16),
                      const Text(
                        'Tax Benefit: Section 80G of Income Tax Act 1961.\nShaheed Foundation (CIN: U85300HR2022NPL101988)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryNavy,
                          side: const BorderSide(color: AppTheme.secondaryNavy),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Official receipt downloaded')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Save Slip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: AppTheme.textDark,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _nameCtrl.clear();
                          _emailCtrl.clear();
                          _phoneCtrl.clear();
                          _panCtrl.clear();
                          _customAmountCtrl.clear();
                        },
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? AppTheme.primaryGoldDark : AppTheme.secondaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
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
            const Text('Donation'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCampaigns,
        color: AppTheme.secondaryNavy,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    'Donation',
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
                        ' /  Donation',
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
              maxWidth: 880,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 12 : 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Tag
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 3,
                        color: AppTheme.primaryGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DONATION',
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
                    'Your Contribution Brings Hope to Martyrs’ Families',
                    style: TextStyle(
                      color: AppTheme.secondaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Every donation helps us support the families of our brave martyrs with dignity, care, and long-term security.',
                    style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),



                  // Featured Campaigns (Dynamic with local fallback)
                  if (_dynamicCampaigns.isNotEmpty)
                    ..._dynamicCampaigns.map((c) {
                      final title = c['title']?.toString() ?? 'Welfare Cause';
                      final tag = c['category']?.toString() ?? 'Welfare';
                      final raised = (double.tryParse(c['raised_amount']?.toString() ?? '0') ?? 0).toInt();
                      final goal = (double.tryParse(c['goal_amount']?.toString() ?? '100000') ?? 100000).toInt();
                      final percent = goal > 0 ? ((raised / goal) * 100).clamp(0, 100).toInt() : 0;
                      final desc = c['description']?.toString() ?? '';
                      final img = c['image_url']?.toString() ?? 'assets/images/army2.jpg';
                      final cid = int.tryParse(c['id']?.toString() ?? '0');
                      final isSelected = _selectedCampaignId == cid;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCampaignId = isSelected ? null : cid;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: isSelected
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.primaryGold, width: 2.5),
                                )
                              : null,
                          child: _buildCampaignCard(
                            title: title,
                            badge: isSelected ? '✓ Selected Cause' : tag,
                            raised: '₹${NumberFormat('#,##,###').format(raised)}',
                            goal: '₹${NumberFormat('#,##,###').format(goal)}',
                            percent: percent,
                            desc: desc,
                            imagePath: img,
                          ),
                        ),
                      );
                    })
                  else ...[
                    _buildCampaignCard(
                      title: 'Support for Martyrs’ Families',
                      badge: 'Family Aid',
                      raised: '₹8,00,000',
                      goal: '₹10,00,000',
                      percent: 85,
                      desc: 'Provides monthly sustenance kits, household essentials, and financial assistance to martyr families.',
                      imagePath: 'assets/images/army2.jpg',
                    ),
                    _buildCampaignCard(
                      title: 'Medical & Health Care Support',
                      badge: 'Healthcare',
                      raised: '₹5,20,000',
                      goal: '₹6,00,000',
                      percent: 95,
                      desc: 'Offers medical treatment, critical surgeries, and chronic prescription medicines for elderly parents.',
                      imagePath: 'assets/images/health.jpg',
                    ),
                    _buildCampaignCard(
                      title: 'Education for Martyrs’ Children',
                      badge: 'Education',
                      raised: '₹3,75,000',
                      goal: '₹5,00,000',
                      percent: 75,
                      desc: 'Covers full tuition, school bags, digital tablets, and competitive exam coaching for martyr children.',
                      imagePath: 'assets/images/education-child.webp',
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 80G Tax Exemption Notice Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryGold.withAlpha(70)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGoldDark, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '50% Tax Exemption Under Section 80G',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryNavy,
                                ),
                              ),
                              Text(
                                'Shaheed Foundation is an authorized Section 8 non-profit. Instant 80G certificates issued.',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Donation Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Make a Meaningful Contribution',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                        ),
                        const SizedBox(height: 14),

                        // Preset Amounts
                        const Text(
                          'Select Donation Amount',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._presetAmounts.map((amt) {
                              final selected = !_isCustom && _selectedAmount == amt;
                              return ChoiceChip(
                                label: Text('₹${NumberFormat('#,##,###').format(amt)}'),
                                selected: selected,
                                selectedColor: AppTheme.primaryGold,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected ? AppTheme.textDark : AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _isCustom = false;
                                      _selectedAmount = amt;
                                    });
                                  }
                                },
                              );
                            }),
                            ChoiceChip(
                              label: const Text('Custom Amount'),
                              selected: _isCustom,
                              selectedColor: AppTheme.primaryGold,
                              backgroundColor: Colors.white,
                              labelStyle: const TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              onSelected: (val) {
                                setState(() {
                                  _isCustom = true;
                                });
                              },
                            ),
                          ],
                        ),

                        if (_isCustom) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _customAmountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Enter Amount (₹)',
                              prefixText: '₹ ',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],

                        const SizedBox(height: 12),
                        // Dynamic Impact Message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.warmCream,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              left: BorderSide(color: AppTheme.primaryGold, width: 4),
                            ),
                          ),
                          child: Text(
                            _impactMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryNavy,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Donor Details
                        const Text(
                          'Donor Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address (for 80G receipt) *',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email address' : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number *',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (val) => val == null || val.trim().length < 10 ? 'Enter a valid 10-digit number' : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _panCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'PAN Number (Optional, for 80G claim)',
                            hintText: 'ABCDE1234F',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment Methods
                        const Text(
                          'Payment Option',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedPaymentMethod = 'UPI'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'UPI'
                                        ? AppTheme.primaryGold.withAlpha(30)
                                        : Colors.white,
                                    border: Border.all(
                                      color: _selectedPaymentMethod == 'UPI'
                                          ? AppTheme.primaryGold
                                          : AppTheme.cardBorder,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.qr_code_rounded, color: AppTheme.secondaryNavy),
                                      SizedBox(height: 4),
                                      Text('UPI / QR / Apps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedPaymentMethod = 'Bank'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'Bank'
                                        ? AppTheme.primaryGold.withAlpha(30)
                                        : Colors.white,
                                    border: Border.all(
                                      color: _selectedPaymentMethod == 'Bank'
                                          ? AppTheme.primaryGold
                                          : AppTheme.cardBorder,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.account_balance, color: AppTheme.secondaryNavy),
                                      SizedBox(height: 4),
                                      Text('Bank Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (_selectedPaymentMethod == 'UPI') _buildUpiCard(context),
                        if (_selectedPaymentMethod == 'Bank') _buildBankCard(context),

                        const SizedBox(height: 14),

                        CheckboxListTile(
                          value: _agreedToTerms,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) => setState(() => _agreedToTerms = v ?? true),
                          title: const Text(
                            'I voluntarily make this contribution to SHAHEED FOUNDATION (Sec 8 Co.) for martyr welfare. Funds are from lawful sources.',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: AppTheme.textDark,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _processDonation,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.textDark,
                                    ),
                                  )
                                : const Icon(Icons.volunteer_activism_rounded, color: AppTheme.textDark),
                            label: Text(
                              _isSubmitting
                                  ? 'Processing Contribution...'
                                  : 'Donate ₹${NumberFormat('#,##,###').format(_currentAmount.toInt())} Now',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCampaignCard({
    required String title,
    required String badge,
    required String raised,
    required String goal,
    required int percent,
    required String desc,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                imagePath,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 130,
                  color: AppTheme.secondaryNavy,
                  child: const Center(
                    child: Icon(Icons.favorite, color: Colors.white24, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 11,
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
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: (percent / 100).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return LinearProgressIndicator(
                        value: val,
                        minHeight: 6,
                        backgroundColor: AppTheme.cardBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Raised: $raised ($percent%)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGoldDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Goal: $goal',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, upiConstraints) {
              final isNarrow = upiConstraints.maxWidth < 340;
              return Row(
                children: [
                  const Icon(Icons.payments_rounded, color: AppTheme.primaryGoldDark, size: 18),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'UPI Instant Payment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.secondaryNavy),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warmCream,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Zero Charges',
                        style: TextStyle(fontSize: 10, color: AppTheme.secondaryNavy, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.warmCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Official UPI ID', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      Text(
                        AppConstants.upiId,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppTheme.primaryGoldDark, size: 18),
                  tooltip: 'Copy UPI ID',
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: AppConstants.upiId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPI ID copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Axis Bank Official Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryNavy)),
          const SizedBox(height: 8),
          _detailLine(context, 'Account Name', AppConstants.bankAccountName),
          _detailLine(context, 'Bank', AppConstants.bankName),
          _detailLine(context, 'Account No.', AppConstants.bankAccountNumber, isCopyable: true),
          _detailLine(context, 'IFSC Code', AppConstants.bankIfsc, isCopyable: true),
          _detailLine(context, 'Branch', AppConstants.bankBranch),
        ],
      ),
    );
  }

  Widget _detailLine(BuildContext context, String title, String val, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    val,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: val));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title copied!')),
                      );
                    },
                    child: const Icon(Icons.copy, size: 13, color: AppTheme.primaryGoldDark),
                  ),
                ],
              ],
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
          _navChip('Donation', isActive: true, onTap: () {}),
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
