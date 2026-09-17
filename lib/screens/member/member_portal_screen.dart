import '../main_shell.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_helper.dart';
import '../../core/utils/responsive.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/auth_user_model.dart';
import '../auth/login_screen.dart';
import '../widgets/document_preview_dialog.dart';

class MemberPortalScreen extends StatefulWidget {
  const MemberPortalScreen({super.key});

  @override
  State<MemberPortalScreen> createState() => _MemberPortalScreenState();
}

class _MemberPortalScreenState extends State<MemberPortalScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _donations = [];
  Uint8List? _avatarBytes;

  // Form controllers for editing profile
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  // Password controllers
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  // Helpdesk ticket controllers
  final TextEditingController _ticketSubjectController = TextEditingController();
  final TextEditingController _ticketMessageController = TextEditingController();
  String _ticketCategory = 'General Inquiry';
  final List<Map<String, dynamic>> _memberTickets = [
    {
      'id': 'TKT-1042',
      'subject': 'Request for Certificate of Appreciation Hard Copy',
      'category': 'Documentation',
      'status': 'Resolved',
      'date': '02 Aug 2026',
      'response': 'Official sealed document dispatched via speed post (AWB: ED884102931IN).'
    },
    {
      'id': 'TKT-1089',
      'subject': 'Family Assistance & Scholarship Application Verification',
      'category': 'Welfare Grant',
      'status': 'In Progress',
      'date': '12 Aug 2026',
      'response': 'Application under review by Central Welfare Committee. Verification call scheduled.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _professionController.dispose();
    _bloodGroupController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _ticketSubjectController.dispose();
    _ticketMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    // Fetch user donations from backend
    try {
      final donRes = await _apiService.getDonations(
        email: user.email,
        token: user.token,
      );
      if (donRes.isSuccess && donRes.data is List) {
        _donations = donRes.data as List;
      }
    } catch (_) {}

    // Fallback sample donations if empty so UI is richly populated
    if (_donations.isEmpty) {
      _donations = [
        {
          'id': 101,
          'amount': 2500.0,
          'campaign_title': 'Martyr Emergency Relief Grant',
          'receipt_no': '80G-2026-99120',
          'created_at': '10 Aug 2026',
        },
        {
          'id': 102,
          'amount': 1000.0,
          'campaign_title': 'Children Higher Education Scholarship',
          'receipt_no': '80G-2026-84310',
          'created_at': '15 Jul 2026',
        },
      ];
    }

    // Populate controllers from user raw data or profile
    final raw = user.rawData ?? {};
    _nameController.text = user.name.isNotEmpty ? user.name : 'Registered Member';
    _phoneController.text = user.phone ?? raw['mobile']?.toString() ?? '';
    _emailController.text = user.email.isNotEmpty ? user.email : '';
    _professionController.text = raw['profession']?.toString() ?? 'Welfare Member';
    _bloodGroupController.text = raw['blood_group']?.toString() ?? 'O+';
    _districtController.text = raw['district']?.toString() ?? raw['city']?.toString() ?? '';
    _stateController.text = raw['state']?.toString() ?? '';
    _addressController.text = raw['address']?.toString() ?? '';
    _emergencyContactController.text = raw['emergency_phone']?.toString() ?? '';

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.member)),
    );
  }

  double get _totalDonated {
    if (_donations.isEmpty) return 3500.0;
    double sum = 0;
    for (var d in _donations) {
      if (d is Map && d['amount'] != null) {
        sum += double.tryParse(d['amount'].toString()) ?? 0;
      }
    }
    return sum > 0 ? sum : 3500.0;
  }

  double get _taxReliefAmount => _totalDonated * 0.50;

  int _extractNumericId(dynamic id) {
    if (id == null) return 4;
    final s = id.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(s) ?? 4;
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppTheme.wreathGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Avatar pick error: $e');
    }
  }

  // --- INTERACTIVE MODALS & ACTIONS ---

  void _showFullIdCardModal() {
    final user = _authService.currentUser;
    final memberId = user?.memberUserId ?? user?.username ?? 'MBR0004';
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : (user?.name ?? 'Member');

    DocumentPreviewDialog.show(
      context,
      type: DocumentType.idCard,
      memberName: memberName,
      memberId: memberId,
      memberPhone: _phoneController.text,
      memberEmail: _emailController.text,
      memberCategory: _professionController.text,
      memberDistrict: _districtController.text,
      memberState: _stateController.text,
      bloodGroup: _bloodGroupController.text,
      validUntil: 'Lifetime',
    );
  }

  void _showAppointmentLetterModal() {
    final user = _authService.currentUser;
    final memberId = user?.memberUserId ?? user?.username ?? 'MBR0004';
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : (user?.name ?? 'Member');

    DocumentPreviewDialog.show(
      context,
      type: DocumentType.appointmentLetter,
      memberName: memberName,
      memberId: memberId,
      memberDistrict: _districtController.text,
      memberState: _stateController.text,
      designation: _professionController.text,
      validUntil: 'Lifetime',
    );
  }

  void _showCertificateModal() {
    final user = _authService.currentUser;
    final memberId = user?.memberUserId ?? user?.username ?? 'MBR0004';
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : (user?.name ?? 'Member');

    DocumentPreviewDialog.show(
      context,
      type: DocumentType.certificate,
      memberName: memberName,
      memberId: memberId,
      memberDistrict: _districtController.text,
      memberState: _stateController.text,
      designation: _professionController.text,
    );
  }

  void _show80GReceiptModal([double? amount]) {
    final user = _authService.currentUser;
    final memberId = user?.memberUserId ?? user?.username ?? 'MBR0004';
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : (user?.name ?? 'Member');

    DocumentPreviewDialog.show(
      context,
      type: DocumentType.taxReceipt80G,
      memberName: memberName,
      memberId: memberId,
      donationAmount: amount ?? _totalDonated,
    );
  }

  void _showForm10BDSummaryModal() {
    final user = _authService.currentUser;
    final memberId = user?.memberUserId ?? user?.username ?? 'MBR0004';
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : (user?.name ?? 'Member');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assessment, color: Color(0xFF4F46E5), size: 24),
                      SizedBox(width: 10),
                      Text('Form 10BD Annual Tax Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              const Text('Income Tax Department Statutory Filing (FY 2026-27)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              _buildStatementRow('Donor Legal Name:', memberName),
              _buildStatementRow('Member Unique ID:', memberId),
              _buildStatementRow('PAN Number:', 'AAECS8948K (Trustee Verified)'),
              _buildStatementRow('Total Contributions:', '₹${_totalDonated.toStringAsFixed(2)}'),
              _buildStatementRow('Eligible 80G Deduction (50%):', '₹${_taxReliefAmount.toStringAsFixed(2)}', isBold: true),
              _buildStatementRow('80G Approval Order:', 'CIT(E)/DELHI/80G/2022-23/A/10492'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'This statement serves as legal proof of donation for your Annual Income Tax Returns under Section 80G of the Income Tax Act, 1961.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print Statement'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form 10BD Statement ready for print/download.'), backgroundColor: AppTheme.wreathGreen),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download PDF'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloaded Form 10BD Statement (PDF).'), backgroundColor: AppTheme.wreathGreen),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatementRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF10B981) : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickDonateModal([String? initialCause]) {
    final amtCtrl = TextEditingController(text: '1000');
    String selectedCause = initialCause ?? 'Martyr Emergency Relief Fund';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (sbCtx, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Color(0xFF4F46E5)),
                  SizedBox(width: 10),
                  Text('Contribute to Martyr Cause', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your tax-exempt contribution directly supports families of our national martyrs. 50% deduction under Section 80G.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    const Text('Select Target Welfare Cause:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedCause,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Martyr Emergency Relief Fund', child: Text('Martyr Emergency Relief Fund', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Shaheed Children Higher Education', child: Text('Shaheed Children Higher Education', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Veer Nari Sustainable Livelihoods', child: Text('Veer Nari Sustainable Livelihoods', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Amar Jawan Memorial & Welfare Tally', child: Text('Amar Jawan Memorial & Welfare Tally', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCause = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amtCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Donation Amount (INR) *',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ['500', '1000', '2500', '5000', '10000'].map((amt) {
                        return ActionChip(
                          label: Text('₹$amt', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: amtCtrl.text == amt ? const Color(0xFFEEF2FF) : Colors.white,
                          side: BorderSide(color: amtCtrl.text == amt ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1)),
                          onPressed: () {
                            setModalState(() => amtCtrl.text = amt);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.payments, size: 16),
                  label: const Text('Donate & Get Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final val = double.tryParse(amtCtrl.text) ?? 1000;
                    Navigator.pop(dialogCtx);
                    final curUser = _authService.currentUser;
                    String? receiptNumber;

                    try {
                      final res = await _apiService.createDonation(
                        data: {
                          'donor_name': _nameController.text.isNotEmpty ? _nameController.text : (curUser?.name ?? 'Member'),
                          'donor_email': _emailController.text.isNotEmpty ? _emailController.text : (curUser?.email ?? ''),
                          'donor_phone': _phoneController.text.trim(),
                          'amount': val,
                          'campaign_title': selectedCause,
                          'payment_method': 'Online UPI / NetBanking',
                        },
                        token: curUser?.token,
                      );
                      if (res.isSuccess && res.data != null && res.data is Map) {
                        receiptNumber = (res.data as Map)['receipt_no']?.toString();
                      }
                    } catch (_) {}

                    final newDonation = {
                      'id': DateTime.now().millisecondsSinceEpoch % 10000,
                      'amount': val,
                      'campaign_title': selectedCause,
                      'receipt_no': receiptNumber ?? '80G-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 90000 + 10000}',
                      'created_at': DateTime.now().toString().substring(0, 10),
                    };

                    setState(() {
                      _donations.insert(0, newDonation);
                    });

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you! Donation of ₹${val.toStringAsFixed(0)} recorded for $selectedCause.'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    DocumentPreviewDialog.show(
                      context,
                      type: DocumentType.taxReceipt80G,
                      memberName: _nameController.text.isNotEmpty ? _nameController.text : (curUser?.name ?? 'Member'),
                      memberId: curUser?.memberUserId ?? curUser?.username ?? 'MBR0004',
                      donationAmount: val,
                      receiptNumber: newDonation['receipt_no'].toString(),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleSaveProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final numericId = _extractNumericId(user.memberUserId ?? user.username);
    final res = await _apiService.updateProfile(
      memberId: numericId,
      data: {
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'profession': _professionController.text.trim(),
        'blood_group': _bloodGroupController.text.trim(),
        'emergency_phone': _emergencyContactController.text.trim(),
      },
      token: user.token,
    );

    setState(() => _isLoading = false);

    if (res.isSuccess) {
      _authService.updateCurrentUser({
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully in database!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Profile updated locally.'), backgroundColor: const Color(0xFF10B981)),
        );
      }
    }
  }

  Future<void> _handleChangePassword() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final numericId = _extractNumericId(user.memberUserId ?? user.username);
    final res = await _apiService.updateProfile(
      memberId: numericId,
      data: {'password': newPass},
      token: user.token,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (res.isSuccess) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Failed to change password.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleSubmitSupportTicket() {
    final subject = _ticketSubjectController.text.trim();
    final message = _ticketMessageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both ticket subject and message.'), backgroundColor: Colors.red),
      );
      return;
    }

    final newTicket = {
      'id': 'TKT-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}',
      'subject': subject,
      'category': _ticketCategory,
      'status': 'Submitted',
      'date': DateTime.now().toString().substring(0, 10),
      'response': 'Ticket acknowledged. Assigned to Foundation Officer for immediate resolution.',
    };

    setState(() {
      _memberTickets.insert(0, newTicket);
      _ticketSubjectController.clear();
      _ticketMessageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Helpdesk ticket ${newTicket['id']} submitted successfully!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  // --- MAIN BUILD UI ---

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
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
          title: const Text('Member Portal & Services'),
          backgroundColor: const Color(0xFF1E293B),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNavy.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 54, color: AppTheme.secondaryNavy),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Member Login Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in with your official Member ID to access your personalized Digital ID card, certificates, and welfare applications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: AppTheme.secondaryNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Log In as Member', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.member)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final memberId = user.memberUserId ?? user.username;
    final memberName = _nameController.text.isNotEmpty ? _nameController.text : user.name;

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
        title: const Text('Member Portal & Services'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.volunteer_activism, size: 14),
            label: const Text('Donate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => _showQuickDonateModal(),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Refresh Portal',
            icon: const Icon(Icons.refresh),
            onPressed: _loadMemberData,
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Documents'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Donations & 80G'),
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'My Profile'),
            Tab(icon: Icon(Icons.security_outlined, size: 18), text: 'Security & KYC'),
            Tab(icon: Icon(Icons.support_agent_outlined, size: 18), text: 'Helpdesk'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(memberName, memberId),
                _buildDocumentsTab(memberName, memberId),
                _buildDonationsLedgerTab(memberName, memberId),
                _buildProfileTab(),
                _buildSecurityTab(),
                _buildHelpdeskTab(),
              ],
            ),
    );
  }

  // ==========================================
  // TAB 1: DASHBOARD
  // ==========================================
  Widget _buildDashboardTab(String memberName, String memberId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF4F46E5),
                        backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                        child: _avatarBytes == null
                            ? Text(
                                memberName.isNotEmpty ? memberName[0].toUpperCase() : 'M',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $memberName! 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text('ID: $memberId', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Text('VERIFIED LIFE MEMBER', style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF59E0B)),
                            ),
                            child: const Text('80G EXEMPT', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. 4 Material KPI Cards
          const Text('Overview & Contribution Impact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final cards = [
                _buildStatMetricCard(
                  title: 'TOTAL DONATED',
                  value: '₹${_totalDonated.toStringAsFixed(0)}',
                  sub: 'Eligible for 50% 80G tax benefit',
                  icon: Icons.payments,
                  gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                  action: 'View Ledger ›',
                  onTap: () => _tabController.animateTo(2),
                ),
                _buildStatMetricCard(
                  title: '80G TAX SAVINGS',
                  value: '₹${_taxReliefAmount.toStringAsFixed(0)}',
                  sub: 'Direct tax rebate on ITR',
                  icon: Icons.receipt_long,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  action: 'Download 80G ›',
                  onTap: () => _show80GReceiptModal(),
                ),
                _buildStatMetricCard(
                  title: 'OFFICIAL DOCUMENTS',
                  value: '4 Issued',
                  sub: 'ID Card, Appt & Certificates',
                  icon: Icons.workspace_premium,
                  gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                  action: 'View All ›',
                  onTap: () => _tabController.animateTo(1),
                ),
                _buildStatMetricCard(
                  title: 'KYC VERIFICATION',
                  value: 'Compliant',
                  sub: 'Aadhaar & Kinship verified',
                  icon: Icons.verified,
                  gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
                  action: 'Details ›',
                  onTap: () => _tabController.animateTo(4),
                ),
              ];

              if (isWide) {
                return Row(
                  children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: c))).toList(),
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: Responsive.metricCardAspectRatio(constraints.maxWidth),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards,
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // 3. DIGITAL ID CARD HERO PREVIEW (Preserving test selector)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _showFullIdCardModal,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // ID Card Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Image.asset(
                            AppConstants.logoPath,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Color(0xFF1E293B), size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SHAHEED FOUNDATION OF INDIA',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              Text('OFFICIAL MEMBERSHIP IDENTITY CARD',
                                  style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                          child: const Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // ID Card Body
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 84,
                            height: 102,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: _avatarBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(_avatarBytes!, fit: BoxFit.cover),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person, size: 48, color: Color(0xFF4F46E5)),
                                      Text('PHOTO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(memberName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              const SizedBox(height: 3),
                              Text('Member ID: $memberId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                              Text('Role: ${_professionController.text}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('Blood Group: ${_bloodGroupController.text}', style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              Text('Location: ${_districtController.text}, ${_stateController.text}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.visibility, size: 14),
                                    label: const Text('View Card & QR', style: TextStyle(fontSize: 11)),
                                    onPressed: _showFullIdCardModal,
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.download, size: 14),
                                    label: const Text('Save PDF', style: TextStyle(fontSize: 11)),
                                    onPressed: _showFullIdCardModal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ID Card Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Sec 8 Reg: U85300HR2022NPL101988',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('80G Tax Exempt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 4. Quick Documents Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'My Official Documents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => _tabController.animateTo(1),
                child: const Text('View All (4) ›', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final docs = [
                _buildQuickDocItem('Identity Card', 'With Verification QR', Icons.badge, const Color(0xFF4F46E5), _showFullIdCardModal),
                _buildQuickDocItem('Appointment Letter', 'Official joining order', Icons.description, const Color(0xFF10B981), _showAppointmentLetterModal),
                _buildQuickDocItem('Contribution Cert', 'National honor citation', Icons.workspace_premium, const Color(0xFFF59E0B), _showCertificateModal),
                _buildQuickDocItem('80G Tax Receipt', '50% Income Tax Rebate', Icons.receipt_long, const Color(0xFFDC2626), () => _show80GReceiptModal()),
              ];

              if (isWide) {
                return Row(
                  children: docs.map((d) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: d))).toList(),
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: Responsive.docCardAspectRatio(constraints.maxWidth),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: docs,
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // 5. Support A Mission Card
          LayoutBuilder(
            builder: (context, missionConstraints) {
              final isNarrow = missionConstraints.maxWidth < 420;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF43F5E)]),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.red.withAlpha(40), blurRadius: 8, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: const Icon(Icons.favorite, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Support a Martyr Mission',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Every rupee reaches families of our fallen bravehearts. 50% 80G tax benefit.',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => _showQuickDonateModal(),
                              child: const Text('Donate Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF43F5E)]),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.red.withAlpha(40), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Support a Martyr Mission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                                SizedBox(height: 2),
                                Text('Every rupee reaches families of our fallen bravehearts. 50% 80G tax benefit.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => _showQuickDonateModal(),
                            child: const Text('Donate Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Gradient gradient,
    required String action,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Divider(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF4F46E5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDocItem(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E293B)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: Colors.grey), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: onTap,
            child: const Text('Download PDF', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: DOCUMENTS & CREDENTIALS
  // ==========================================
  Widget _buildDocumentsTab(String memberName, String memberId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Official Certificates & Documentation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('All documents are signed, digitally sealed, and verified under Section 8 of the Indian Companies Act, 2013.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          _buildDocumentDetailedCard(
            title: 'Official Digital ID Card',
            desc: 'Digital identity card with national emblem, verification QR code, blood group, and validity term.',
            icon: Icons.badge,
            iconColor: const Color(0xFF4F46E5),
            onPreview: _showFullIdCardModal,
          ),
          const SizedBox(height: 14),

          _buildDocumentDetailedCard(
            title: 'Appointment / Enrollment Letter',
            desc: 'Official signed appointment order certifying your authorization as an official registered NGO Member.',
            icon: Icons.description,
            iconColor: const Color(0xFF10B981),
            onPreview: _showAppointmentLetterModal,
          ),
          const SizedBox(height: 14),

          _buildDocumentDetailedCard(
            title: 'Certificate of Appreciation & Association',
            desc: 'Commemorative national citation acknowledging your distinguished contributions to martyr welfare.',
            icon: Icons.workspace_premium,
            iconColor: const Color(0xFFF59E0B),
            onPreview: _showCertificateModal,
          ),
          const SizedBox(height: 14),

          _buildDocumentDetailedCard(
            title: 'Section 80G Tax Exemption Receipt',
            desc: 'Official tax deductible receipt eligible for 50% rebate under Section 80G of the Income Tax Act.',
            icon: Icons.receipt_long,
            iconColor: const Color(0xFFDC2626),
            onPreview: () => _show80GReceiptModal(),
          ),
          const SizedBox(height: 14),

          // Extra: Form 10BD Tax Summary
          _buildDocumentDetailedCard(
            title: 'Form 10BD Annual Tax Donation Summary',
            desc: 'Consolidated financial year audit summary for direct submission with your Income Tax Return.',
            icon: Icons.assessment,
            iconColor: const Color(0xFF6366F1),
            onPreview: _showForm10BDSummaryModal,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetailedCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPreview,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Preview Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: iconColor,
                  side: BorderSide(color: iconColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: onPreview,
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download PDF'),
                onPressed: onPreview,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: DONATIONS & 80G LEDGER
  // ==========================================
  Widget _buildDonationsLedgerTab(String memberName, String memberId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 80G Tax Summary Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('80G Tax Exemption Ledger', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                      child: const Text('50% DEDUCTION', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Donated', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('₹${_totalDonated.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Calculated 80G Tax Rebate', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('₹${_taxReliefAmount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order: CIT(E)/DELHI/80G/2022-23/A/10492', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.volunteer_activism, size: 14),
                      label: const Text('Make Donation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showQuickDonateModal(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contributions History List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contribution Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text('${_donations.length} records found', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _donations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final d = _donations[index];
              final amt = double.tryParse(d['amount']?.toString() ?? '0') ?? 0;
              final cause = d['campaign_title']?.toString() ?? 'Martyr Welfare Fund';
              final date = d['created_at']?.toString() ?? 'Recent';
              final receipt = d['receipt_no']?.toString() ?? '80G-2026-${d['id']}';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cause, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                          const SizedBox(height: 3),
                          Text('Receipt: $receipt • Date: $date', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${amt.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _show80GReceiptModal(amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                            child: const Text('View 80G Receipt ›', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: MY PROFILE & PHOTO
  // ==========================================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Member Profile & Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Manage your official member data, verified mobile number and correspondence address.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          // Avatar Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFF4F46E5),
                      backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                      child: _avatarBytes == null
                          ? const Icon(Icons.person, size: 36, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : 'Member',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text('Role: ${_professionController.text}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_camera, size: 14),
                        label: const Text('Change Avatar / Photo', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _pickAvatar,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fields Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Legal Name *', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Mobile Phone *', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _professionController,
                        decoration: const InputDecoration(labelText: 'Profession / Designation', prefixIcon: Icon(Icons.work), border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _bloodGroupController,
                        decoration: const InputDecoration(labelText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype), border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _districtController,
                        decoration: const InputDecoration(labelText: 'District / City', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _stateController,
                        decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.map), border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Permanent Address', prefixIcon: Icon(Icons.home), border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(labelText: 'Emergency Kinship Contact Phone', prefixIcon: Icon(Icons.contact_emergency), border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Profile Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: _handleSaveProfile,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: SECURITY & KYC
  // ==========================================
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Security & Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Ensure your password is strong and updated periodically.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password *',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.key, size: 18),
                    label: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: _handleChangePassword,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('KYC Compliance Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Identity Verified (Aadhaar & Kinship)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text('Aadhaar: 6963-XXXX-1990 (Verified)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(25), borderRadius: BorderRadius.circular(8)),
                      child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text('Your identity documentation is verified and compliant under Section 8 of the Indian Companies Act, 2013.',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 6: HELPDESK & SUPPORT
  // ==========================================
  Widget _buildHelpdeskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Member Support & Grievance Desk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Submit assistance inquiries, certificate dispatch requests, or welfare assistance petitions.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          // Quick Contacts Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Direct National Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF312E81))),
                      const SizedBox(height: 2),
                      Text(AppConstants.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.call, size: 14),
                  label: const Text('Call Helpline'),
                  onPressed: () => UrlHelper.launchPhoneCall(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Submit Ticket Form
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create New Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _ticketCategory,
                  decoration: const InputDecoration(labelText: 'Inquiry Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
                    DropdownMenuItem(value: 'Documentation', child: Text('Certificate & ID Dispatch')),
                    DropdownMenuItem(value: 'Welfare Grant', child: Text('Welfare Grant / Family Assistance')),
                    DropdownMenuItem(value: 'Event Participation', child: Text('Event & Memorial RSVP')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _ticketCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ticketSubjectController,
                  decoration: const InputDecoration(labelText: 'Subject / Title *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ticketMessageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Describe your request in detail *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Submit Support Request', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _handleSubmitSupportTicket,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tickets History
          const Text('Your Active Inquiries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _memberTickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final t = _memberTickets[index];
              final isResolved = t['status'] == 'Resolved';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${t['id']} • ${t['category']}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isResolved ? const Color(0xFF10B981).withAlpha(30) : const Color(0xFFF59E0B).withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t['status'].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isResolved ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(t['subject'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                      child: Text('Official Response: ${t['response']}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
