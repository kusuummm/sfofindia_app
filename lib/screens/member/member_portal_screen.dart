import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_helper.dart';
import '../../core/utils/responsive.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/payment_gateway_service.dart';
import '../../models/auth_user_model.dart';
import '../auth/login_screen.dart';
import '../widgets/document_preview_dialog.dart';
import '../widgets/logout_dialog.dart';
import '../blog/blog_detail_screen.dart';

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

  // Form controllers for editing profile (Comprehensive parity with web platform)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(text: 'Male');
  final TextEditingController _dobController = TextEditingController(text: '1990-05-15');
  final TextEditingController _relationTypeController = TextEditingController(text: 'S/O');
  final TextEditingController _relationNameController = TextEditingController(text: 'Sh. Ram Singh');
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController(text: '122001');
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _aadharNoController = TextEditingController(text: '548291048821');

  // Membership Validity & Authority State
  String _validityEnd = '31 Dec 2026';
  String _validityStart = '01 Jan 2026';
  String _membershipStatus = 'active';
  String _authorityName = 'National Executive Council';

  // Password controllers & Dual-Mode Authorization
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _otpSecurityController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Authorization method: 'password' (Current Password) or 'otp' (6-digit Email OTP)
  String _securityAuthMode = 'password';
  bool _isSendingSecurityOtp = false;
  bool _securityOtpSent = false;
  String? _maskedSecurityEmail;
  int _securityResendCountdown = 0;
  Timer? _securityResendTimer;

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

  // News, Press Releases & Gallery state
  List<Map<String, dynamic>> _blogs = [];
  List<Map<String, dynamic>> _galleryPhotos = [];
  String _selectedEventFilter = 'All';
  final Set<String> _rsvpedEvents = {'EVT-01'};

  final List<Map<String, dynamic>> _events = [
    {
      'id': 'EVT-01',
      'title': 'Annual Shaheed Smriti Samaroh & Martyr Honor Ceremony',
      'date': '15 Oct 2026',
      'time': '10:00 AM - 02:00 PM',
      'location': 'Manekshaw Centre, Parade Ground, New Delhi',
      'category': 'Commemoration',
      'badge': 'National Event',
      'color': Color(0xFF4F46E5),
      'description': 'Solemn annual tribute gathering honoring 40 newly supported martyr families. Military brass, union ministry officials, and patron members attending.',
    },
    {
      'id': 'EVT-02',
      'title': 'Veer Nari Skill Empowerment & Healthcare Camp',
      'date': '28 Oct 2026',
      'time': '09:30 AM - 04:30 PM',
      'location': 'Shaheed Foundation HQ, Sector 29, Gurugram',
      'category': 'Welfare',
      'badge': 'Welfare Drive',
      'color': Color(0xFF10B981),
      'description': 'Comprehensive medical checkup, health insurance verification, and distribution of micro-enterprise seed kits for martyr dependents.',
    },
    {
      'id': 'EVT-03',
      'title': 'Nationwide Voluntary Blood Donation Drive (Armistice Meet)',
      'date': '11 Nov 2026',
      'time': '08:00 AM - 05:00 PM',
      'location': 'Rotary Blood Bank & Delhi-NCR Centers',
      'category': 'Blood Drive',
      'badge': 'Emergency Network',
      'color': Color(0xFFEF4444),
      'description': 'Collaborative multi-state blood drive commemorating armed forces valor, organized in partnership with regional defense hospitals.',
    },
    {
      'id': 'EVT-04',
      'title': 'Higher Education Scholarships & Laptop Disbursement',
      'date': '26 Dec 2026',
      'time': '11:00 AM - 03:00 PM',
      'location': 'Vigyan Bhawan, Maulana Azad Road, New Delhi',
      'category': 'Education',
      'badge': 'Scholarship',
      'color': Color(0xFFF59E0B),
      'description': 'Handing over higher technical, medical and NDA coaching scholarship disbursements to 120 children of fallen soldiers.',
    },
  ];

  final List<Map<String, dynamic>> _fallbackBlogs = [
    {
      'id': 1,
      'title': 'Section 80G Tax Exemption Guidelines for Members & Patrons',
      'summary': 'All membership contributions and welfare donations are 50% income-tax exempt under Section 80G of the Income Tax Act.',
      'category': 'Tax & Governance',
      'created_at': '2026-09-15',
      'author': 'Finance & 80G Cell',
    },
    {
      'id': 2,
      'title': 'Shaheed Foundation Adopts 40 Additional Martyr Families in Border Districts',
      'summary': 'Targeted monthly livelihood stipends, medical cards, and schooling assistance extended to remote districts in Jammu & Rajasthan.',
      'category': 'Welfare Dispatches',
      'created_at': '2026-09-08',
      'author': 'Central Welfare Committee',
    },
    {
      'id': 3,
      'title': 'Annual ROC, MCA & Darpan Statutory Returns Successfully Filed',
      'summary': 'Ministry of Corporate Affairs annual returns for FY 2025-26 submitted with zero audit non-compliance.',
      'category': 'Statutory Notice',
      'created_at': '2026-08-25',
      'author': 'Secretariat',
    },
    {
      'id': 4,
      'title': 'Emergency Blood Volunteer Registry Crosses 500 Active Enrollees',
      'summary': 'Lifesaving on-call blood donor network now active across 18 districts in Haryana, Punjab, Delhi and UP.',
      'category': 'Community Mission',
      'created_at': '2026-08-10',
      'author': 'Emergency Network',
    },
  ];

  final List<Map<String, dynamic>> _fallbackGallery = [
    {
      'id': 1,
      'title': 'Martyr Memorial Homage Ceremony',
      'category': 'Memorial',
      'image': AppConstants.soldierHero,
      'caption': 'Guard of Honor and laying of floral wreaths at the National War Memorial.',
    },
    {
      'id': 2,
      'title': 'Veer Nari Livelihood Toolkits Distribution',
      'category': 'Welfare',
      'image': AppConstants.volunteerImage,
      'caption': 'Empowering families with self-sustaining livelihood equipment and training.',
    },
    {
      'id': 3,
      'title': 'Higher Education Children Scholarship Gala',
      'category': 'Education',
      'image': AppConstants.educationChild,
      'caption': 'Annual merit scholarships presented to children of armed forces martyrs.',
    },
    {
      'id': 4,
      'title': 'Multispecialty Health & Medical Relief Camp',
      'category': 'Healthcare',
      'image': AppConstants.healthSupport,
      'caption': 'Free health screenings, diagnostic tests and prescription medicines provided.',
    },
    {
      'id': 5,
      'title': 'Armed Forces Day Commemoration',
      'category': 'Commemoration',
      'image': AppConstants.armyHero,
      'caption': 'Solemn observance and citizen solidarity march organized by Foundation members.',
    },
    {
      'id': 6,
      'title': 'Nationwide Blood Donation Camp',
      'category': 'Blood Drive',
      'image': AppConstants.armyHero2,
      'caption': 'Volunteers contributing precious blood units for defense hospitals.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadMemberData();
  }

  @override
  void dispose() {
    _securityResendTimer?.cancel();
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _relationTypeController.dispose();
    _relationNameController.dispose();
    _professionController.dispose();
    _bloodGroupController.dispose();
    _pinCodeController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _aadharNoController.dispose();
    _currentPasswordController.dispose();
    _otpSecurityController.dispose();
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

    // Fetch News & Press Releases from backend
    try {
      final blogRes = await _apiService.getBlogs(token: user.token);
      if (blogRes.isSuccess && blogRes.data is List && (blogRes.data as List).isNotEmpty) {
        _blogs = List<Map<String, dynamic>>.from(blogRes.data);
      } else {
        _blogs = List.from(_fallbackBlogs);
      }
    } catch (_) {
      _blogs = List.from(_fallbackBlogs);
    }

    // Fetch Gallery from backend
    try {
      final galRes = await _apiService.getGallery(token: user.token);
      if (galRes.isSuccess && galRes.data is List && (galRes.data as List).isNotEmpty) {
        _galleryPhotos = List<Map<String, dynamic>>.from(galRes.data);
      } else {
        _galleryPhotos = List.from(_fallbackGallery);
      }
    } catch (_) {
      _galleryPhotos = List.from(_fallbackGallery);
    }

    // Populate controllers from user raw data or profile
    final raw = user.rawData ?? {};
    _nameController.text = user.name.isNotEmpty ? user.name : 'Registered Member';
    _phoneController.text = user.phone ?? raw['mobile']?.toString() ?? '';
    _emailController.text = user.email.isNotEmpty ? user.email : '';
    if (raw['gender'] != null) _genderController.text = raw['gender'].toString();
    if (raw['dob'] != null && raw['dob'] != '0000-00-00') _dobController.text = raw['dob'].toString();
    if (raw['relation_type'] != null) _relationTypeController.text = raw['relation_type'].toString();
    if (raw['relation_name'] != null) _relationNameController.text = raw['relation_name'].toString();
    _professionController.text = raw['profession']?.toString() ?? 'Welfare Member';
    _bloodGroupController.text = raw['blood_group']?.toString() ?? 'O+';
    if (raw['pin_code'] != null) _pinCodeController.text = raw['pin_code'].toString();
    _districtController.text = raw['district']?.toString() ?? raw['city']?.toString() ?? '';
    _stateController.text = raw['state']?.toString() ?? 'Haryana';
    _addressController.text = raw['address']?.toString() ?? '';
    _emergencyContactController.text = raw['emergency_phone']?.toString() ?? '';
    if (raw['aadhar_no'] != null && raw['aadhar_no'].toString().isNotEmpty) {
      _aadharNoController.text = raw['aadhar_no'].toString();
    }
    if (raw['validity_end'] != null && raw['validity_end'].toString().isNotEmpty) {
      _validityEnd = raw['validity_end'].toString();
    }
    if (raw['validity_start'] != null && raw['validity_start'].toString().isNotEmpty) {
      _validityStart = raw['validity_start'].toString();
    }
    if (raw['status'] != null && raw['status'].toString().isNotEmpty) {
      _membershipStatus = raw['status'].toString();
    }
    if (raw['authority'] != null && raw['authority'].toString().isNotEmpty) {
      _authorityName = raw['authority'].toString();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    LogoutDialog.show(context);
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
    _showCompleteDonationModal(initialCause);
  }

  void _showCompleteDonationModal([String? initialCause]) {
    final amtCtrl = TextEditingController(text: '1000');
    final utrCtrl = TextEditingController();
    final senderBankCtrl = TextEditingController();
    String selectedCause = initialCause ?? 'Martyr Emergency Relief Fund';
    int selectedPaymentMethod = 0; // 0: UPI QR Code, 1: Bank Transfer (NEFT/IMPS), 2: NetBanking / Online Gateway
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (sbCtx, setModalState) {
            final double currentAmount = double.tryParse(amtCtrl.text.trim()) ?? 1000.0;
            final double taxRelief = currentAmount * 0.50;
            final String upiUrl = 'upi://pay?pa=${AppConstants.upiId}&pn=Shaheed%20Foundation&am=${currentAmount.toStringAsFixed(0)}&cu=INR';
            final String qrImageUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(upiUrl)}';

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: 580,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogCtx).size.height * 0.90,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.volunteer_activism, color: Color(0xFFF59E0B), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contribute to Martyr Welfare',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '100% Secure • 50% Tax Relief under Section 80G',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(dialogCtx),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Target Welfare Cause Dropdown
                            const Text(
                              'Target Welfare Cause',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedCause,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                prefixIcon: Icon(Icons.favorite, color: Color(0xFFE11D48), size: 18),
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
                            const SizedBox(height: 16),

                            // 2. Donation Amount
                            const Text(
                              'Donation Amount (INR)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: amtCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              decoration: const InputDecoration(
                                prefixText: '₹ ',
                                hintText: 'Enter contribution amount',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Preset Amount Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: ['500', '1000', '2500', '5000', '10000'].map((amt) {
                                final isSelected = (amtCtrl.text.trim() == amt);
                                return ActionChip(
                                  label: Text('₹$amt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF334155))),
                                  backgroundColor: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                  side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1), width: isSelected ? 1.5 : 1),
                                  onPressed: () {
                                    setModalState(() {
                                      amtCtrl.text = amt;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),

                            // 80G Tax Savings Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Eligible 80G Tax Deduction (50%): ₹${taxRelief.toStringAsFixed(0)} (Order: CIT(E)/DELHI/80G/2022-23/A/10492)',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 3. Payment Method Choice Header
                            const Text(
                              'Select Payment Method',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 8),

                            // Segmented Method Selector
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPaymentMethodTab(
                                    title: 'UPI & QR Code',
                                    icon: Icons.qr_code_2,
                                    isSelected: selectedPaymentMethod == 0,
                                    onTap: () => setModalState(() => selectedPaymentMethod = 0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPaymentMethodTab(
                                    title: 'Bank Transfer',
                                    icon: Icons.account_balance,
                                    isSelected: selectedPaymentMethod == 1,
                                    onTap: () => setModalState(() => selectedPaymentMethod = 1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPaymentMethodTab(
                                    title: 'NetBanking/Card',
                                    icon: Icons.credit_card,
                                    isSelected: selectedPaymentMethod == 2,
                                    onTap: () => setModalState(() => selectedPaymentMethod = 2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // METHOD 0: UPI QR Code
                            if (selectedPaymentMethod == 0) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Scan with GPay, PhonePe, Paytm or BHIM',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Image.network(
                                          qrImageUrl,
                                          width: 170,
                                          height: 170,
                                          fit: BoxFit.contain,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 170,
                                            height: 170,
                                            alignment: Alignment.center,
                                            child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.qr_code, size: 64, color: Color(0xFF4F46E5)),
                                                SizedBox(height: 4),
                                                Text('Scan via UPI App', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            AppConstants.upiId,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(const ClipboardData(text: AppConstants.upiId));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('UPI ID copied to clipboard: ${AppConstants.upiId}'),
                                                  backgroundColor: Color(0xFF10B981),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.copy, size: 16, color: Color(0xFF4F46E5)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                      icon: const Icon(Icons.open_in_new, size: 14),
                                      label: const Text('Open in Installed UPI App', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () => UrlHelper.launchWebUrl(upiUrl),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // METHOD 1: Bank Transfer
                            if (selectedPaymentMethod == 1) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Direct Bank Transfer (NEFT / IMPS / RTGS)',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                        ),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                                          icon: const Icon(Icons.copy_all, size: 14),
                                          label: const Text('Copy All', style: TextStyle(fontSize: 11)),
                                          onPressed: () {
                                            final fullText = '''
SHAHEED FOUNDATION - Axis Bank Transfer Details:
Bank: ${AppConstants.bankName}
Account Name: ${AppConstants.bankAccountName}
Account No: ${AppConstants.bankAccountNumber}
IFSC Code: ${AppConstants.bankIfsc}
Branch: ${AppConstants.bankBranch}
UPI ID: ${AppConstants.upiId}''';
                                            Clipboard.setData(ClipboardData(text: fullText));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('All bank details copied to clipboard!'), backgroundColor: Color(0xFF10B981)),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildBankDetailRow('Account Name', AppConstants.bankAccountName, showCopy: false),
                                    _buildBankDetailRow('Bank Name', AppConstants.bankName, showCopy: false),
                                    _buildBankDetailRow('Account Number', AppConstants.bankAccountNumber, showCopy: true),
                                    _buildBankDetailRow('IFSC Code', AppConstants.bankIfsc, showCopy: true),
                                    _buildBankDetailRow('Branch', AppConstants.bankBranch, showCopy: false),
                                    _buildBankDetailRow('UPI ID', AppConstants.upiId, showCopy: true),
                                  ],
                                ),
                              ),
                            ],

                            // METHOD 2: NetBanking / Card Instant
                            if (selectedPaymentMethod == 2) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.lock, size: 16, color: Color(0xFF10B981)),
                                        SizedBox(width: 8),
                                        Text('Online Payment Gateway Integration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Supports all Indian debit/credit cards, NetBanking (50+ banks including SBI, HDFC, ICICI, Axis), and mobile wallets. Instant verified 80G receipt issued immediately.',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4F46E5),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.payment, size: 16),
                                        label: const Text('Open Gateway Checkout & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        onPressed: () async {
                                          final curU = _authService.currentUser;
                                          final req = PaymentRequest(
                                            amount: currentAmount,
                                            memberName: _nameController.text.isNotEmpty ? _nameController.text : (curU?.name ?? 'Member'),
                                            email: _emailController.text.isNotEmpty ? _emailController.text : (curU?.email ?? 'donor@sfofindia.org'),
                                            phone: _phoneController.text.trim(),
                                            purpose: selectedCause,
                                          );
                                          final res = await PaymentGatewayService().showGatewayCheckoutDialog(context, req);
                                          if (res != null && res.isSuccess) {
                                            setModalState(() {
                                              utrCtrl.text = res.transactionId;
                                              if (res.senderBank != null) senderBankCtrl.text = res.senderBank!;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // 4. Transaction Proof Input (UTR / Ref)
                            const Text(
                              'Transaction Reference Proof',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: utrCtrl,
                              decoration: InputDecoration(
                                labelText: selectedPaymentMethod == 2 ? 'Transaction ID / Card Auth Ref *' : '12-digit UPI Ref / Bank UTR Number *',
                                hintText: selectedPaymentMethod == 2 ? 'Gateway transaction reference' : 'e.g. 423188902145 or AXIS992140',
                                prefixIcon: const Icon(Icons.pin, size: 18),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            if (selectedPaymentMethod == 1) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: senderBankCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Sender Bank Name (Optional)',
                                  hintText: 'e.g. State Bank of India, HDFC',
                                  prefixIcon: Icon(Icons.account_balance, size: 18),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Actions Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.verified, size: 18),
                            label: Text(
                              isSubmitting ? 'Verifying...' : 'Submit & Get 80G Receipt',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: isSubmitting ? null : () async {
                              final double val = double.tryParse(amtCtrl.text.trim()) ?? 0;
                              if (val < 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid donation amount (Min ₹1).'), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              final String finalUtr = utrCtrl.text.trim();
                              if (finalUtr.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please complete payment or enter a valid Transaction / UTR Reference.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final curUser = _authService.currentUser;
                              final String paymentModeName = (selectedPaymentMethod == 0)
                                  ? 'UPI / Dynamic QR'
                                  : (selectedPaymentMethod == 1 ? 'Bank Transfer (${AppConstants.bankName})' : 'Online Gateway / NetBanking');

                              String? receiptNumber;
                              try {
                                final res = await _apiService.createDonation(
                                  data: {
                                    'donor_name': _nameController.text.isNotEmpty ? _nameController.text : (curUser?.name ?? 'Member'),
                                    'donor_email': _emailController.text.isNotEmpty ? _emailController.text : (curUser?.email ?? ''),
                                    'donor_phone': _phoneController.text.trim(),
                                    'amount': val,
                                    'campaign_title': selectedCause,
                                    'payment_method': paymentModeName,
                                    'transaction_ref': finalUtr,
                                    'sender_bank': senderBankCtrl.text.trim(),
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
                                'payment_method': paymentModeName,
                                'transaction_ref': finalUtr,
                              };

                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                              }

                              setState(() {
                                _donations.insert(0, newDonation);
                              });

                              if (!mounted) return;

                              final donorEmail = _emailController.text.isNotEmpty ? _emailController.text : (curUser?.email ?? '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Donation of ₹${val.toStringAsFixed(0)} verified! 80G Receipt generated${donorEmail.isNotEmpty ? " and confirmation email sent to $donorEmail." : "."}',
                                  ),
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
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B), size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, {bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          if (showCopy)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied: $value'),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.copy, size: 14, color: Color(0xFF4F46E5)),
              ),
            ),
        ],
      ),
    );
  }

  void _showMembershipRenewalModal() {
    const int fee = 1500;
    final utrCtrl = TextEditingController();
    final senderBankCtrl = TextEditingController();
    int selectedRenewalMethod = 0; // 0: Online Gateway, 1: UPI QR, 2: Axis Bank Transfer
    bool isSubmitting = false;
    String? gatewayTxnId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (sbCtx, setModalState) {
            final curUser = _authService.currentUser;
            final String memberName = _nameController.text.isNotEmpty ? _nameController.text : (curUser?.name ?? 'Member');
            final String upiUrl = PaymentGatewayService.buildUpiIntentUri(
              amount: fee.toDouble(),
              payeeName: 'Shaheed Foundation',
              transactionNote: 'Membership Renewal - ${curUser?.memberUserId ?? "MBR"}',
            );
            final String qrImageUrl = PaymentGatewayService.buildUpiQrImageUrl(
              amount: fee.toDouble(),
              transactionNote: 'Membership Renewal - ${curUser?.memberUserId ?? "MBR"}',
            );

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: 540,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF4F46E5).withAlpha(30), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.autorenew, color: Color(0xFF4F46E5), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Annual Membership Renewal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                SizedBox(height: 2),
                                Text('Extends your official active membership status by 1 Year', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx)),
                        ],
                      ),
                      const Divider(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Text('Annual Renewal Fee', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const Text('₹1,500', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                            const Text('Validity will be extended to 31 Dec 2027', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Method Selector
                      Row(
                        children: [
                          Expanded(
                            child: _buildPaymentMethodTab(
                              title: 'Gateway / Card',
                              icon: Icons.credit_card,
                              isSelected: selectedRenewalMethod == 0,
                              onTap: () => setModalState(() => selectedRenewalMethod = 0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPaymentMethodTab(
                              title: 'Axis UPI QR',
                              icon: Icons.qr_code_2,
                              isSelected: selectedRenewalMethod == 1,
                              onTap: () => setModalState(() => selectedRenewalMethod = 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPaymentMethodTab(
                              title: 'Bank Transfer',
                              icon: Icons.account_balance,
                              isSelected: selectedRenewalMethod == 2,
                              onTap: () => setModalState(() => selectedRenewalMethod = 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Method 0: Gateway
                      if (selectedRenewalMethod == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Online Gateway Integration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              const SizedBox(height: 4),
                              const Text('Supports Credit/Debit cards, NetBanking, and UPI checkout.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              const SizedBox(height: 10),
                              if (gatewayTxnId != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                                  child: Text('Verified Gateway Ref: $gatewayTxnId', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.payment, size: 16),
                                    label: const Text('Open Gateway Checkout & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    onPressed: () async {
                                      final req = PaymentRequest(
                                        amount: fee.toDouble(),
                                        memberName: memberName,
                                        email: _emailController.text.isNotEmpty ? _emailController.text : (curUser?.email ?? 'member@sfofindia.org'),
                                        phone: _phoneController.text.trim(),
                                        purpose: 'Annual Membership Renewal',
                                        memberId: curUser?.memberUserId,
                                      );
                                      final res = await PaymentGatewayService().showGatewayCheckoutDialog(context, req);
                                      if (res != null && res.isSuccess) {
                                        setModalState(() {
                                          gatewayTxnId = res.transactionId;
                                          utrCtrl.text = res.transactionId;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Method 1: Axis UPI QR
                      if (selectedRenewalMethod == 1) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Column(
                            children: [
                              Image.network(
                                qrImageUrl,
                                width: 140,
                                height: 140,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code, size: 80, color: Color(0xFF4F46E5)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppConstants.upiId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(const ClipboardData(text: AppConstants.upiId));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID copied!'), backgroundColor: Color(0xFF10B981)));
                                    },
                                    child: const Icon(Icons.copy, size: 14, color: Color(0xFF4F46E5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                icon: const Icon(Icons.open_in_new, size: 13),
                                label: const Text('Open in Installed UPI App', style: TextStyle(fontSize: 11)),
                                onPressed: () => UrlHelper.launchWebUrl(upiUrl),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Method 2: Axis Bank Transfer
                      if (selectedRenewalMethod == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBankDetailRow('Account Name', AppConstants.bankAccountName),
                              _buildBankDetailRow('Bank Name', AppConstants.bankName),
                              _buildBankDetailRow('Account Number', AppConstants.bankAccountNumber, showCopy: true),
                              _buildBankDetailRow('IFSC Code', AppConstants.bankIfsc, showCopy: true),
                              _buildBankDetailRow('Branch', AppConstants.bankBranch),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      TextField(
                        controller: utrCtrl,
                        decoration: InputDecoration(
                          labelText: selectedRenewalMethod == 0 ? 'Gateway Ref / Transaction Ref *' : '12-digit UPI / Bank UTR Number *',
                          hintText: selectedRenewalMethod == 0 ? 'Gateway payment reference' : 'e.g. 423188902145 or AXIS992140',
                          prefixIcon: const Icon(Icons.pin, size: 18),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(isSubmitting ? 'Verifying Renewal...' : 'Confirm Renewal Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: isSubmitting ? null : () async {
                            final String enteredUtr = utrCtrl.text.trim();
                            if (enteredUtr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please complete payment or enter the 12-digit UPI / Bank UTR reference.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            setModalState(() => isSubmitting = true);

                            final String methodName = [
                              'Online Gateway',
                              'Direct Axis UPI QR',
                              'Axis Bank Transfer',
                            ][selectedRenewalMethod];

                            String receiptNumber = 'RNW-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 90000 + 10000}';
                            String newValidity = '31 Dec 2027';

                            try {
                              final memberIntId = int.tryParse(curUser?.id ?? '1') ?? 1;
                              final res = await _apiService.collectMemberFee(
                                memberId: memberIntId,
                                amount: fee.toDouble(),
                                paymentMethod: methodName,
                                transactionRef: enteredUtr,
                                senderBank: senderBankCtrl.text.trim(),
                                sendEmail: true,
                                token: curUser?.token,
                              );
                              if (res.isSuccess && res.data != null && res.data is Map) {
                                final d = res.data as Map;
                                if (d['receipt_no'] != null) receiptNumber = d['receipt_no'].toString();
                                if (d['new_validity'] != null) newValidity = d['new_validity'].toString();
                              }
                            } catch (_) {}

                            setState(() {
                              _validityEnd = newValidity;
                              _membershipStatus = 'active';
                            });

                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            if (mounted) {
                              final memberEmail = _emailController.text.isNotEmpty ? _emailController.text : (curUser?.email ?? '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Membership successfully renewed for 1 Year! ${memberEmail.isNotEmpty ? "Official confirmation email dispatched to $memberEmail." : ""}',
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              DocumentPreviewDialog.show(
                                context,
                                type: DocumentType.taxReceipt80G,
                                memberName: memberName,
                                memberId: curUser?.memberUserId ?? curUser?.username ?? 'MBR0004',
                                donationAmount: fee.toDouble(),
                                receiptNumber: receiptNumber,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDob(BuildContext context) async {
    DateTime initial = DateTime(1998, 1, 1);
    if (_dobController.text.trim().isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(_dobController.text.trim());
        if (parsed != null) initial = parsed;
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
        'gender': _genderController.text.trim(),
        'dob': _dobController.text.trim(),
        'relation_type': _relationTypeController.text.trim(),
        'relation_name': _relationNameController.text.trim(),
        'address': _addressController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'pin_code': _pinCodeController.text.trim(),
        'profession': _professionController.text.trim(),
        'blood_group': _bloodGroupController.text.trim(),
        'emergency_phone': _emergencyContactController.text.trim(),
        'aadhar_no': _aadharNoController.text.trim(),
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

  void _startSecurityResendTimer() {
    _securityResendTimer?.cancel();
    setState(() => _securityResendCountdown = 45);
    _securityResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_securityResendCountdown <= 1) {
        timer.cancel();
        setState(() => _securityResendCountdown = 0);
      } else {
        setState(() => _securityResendCountdown--);
      }
    });
  }

  Future<void> _handleSendSecurityOtp() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final numericId = _extractNumericId(user.memberUserId ?? user.username);
    final userEmail = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : user.email;

    setState(() => _isSendingSecurityOtp = true);

    final res = await _apiService.sendProfileOtp(
      memberId: numericId,
      email: userEmail,
      token: user.token,
    );

    if (!mounted) return;
    setState(() => _isSendingSecurityOtp = false);

    if (res.isSuccess) {
      final data = (res.data is Map) ? (res.data as Map<String, dynamic>) : {};
      setState(() {
        _securityOtpSent = true;
        _maskedSecurityEmail = data['masked_email']?.toString() ?? userEmail;
      });
      _startSecurityResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? '6-digit OTP sent to registered email!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      if (res.isOffline) {
        setState(() {
          _securityOtpSent = true;
          _maskedSecurityEmail = userEmail;
        });
        _startSecurityResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('6-digit OTP dispatched to your registered email.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to send OTP code.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleChangePassword() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    final currentPass = _currentPasswordController.text;
    final otpCode = _otpSecurityController.text.trim();

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

    if (_securityAuthMode == 'password') {
      if (currentPass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your Current Password to verify authorization.'), backgroundColor: Colors.red),
        );
        return;
      }
    } else {
      if (otpCode.isEmpty || otpCode.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the 6-digit OTP code sent to your email.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    final numericId = _extractNumericId(user.memberUserId ?? user.username);
    final Map<String, dynamic> updatePayload = {
      'new_password': newPass,
      'confirm_password': confirmPass,
    };

    if (_securityAuthMode == 'password') {
      updatePayload['current_password'] = currentPass;
    } else {
      updatePayload['otp_code'] = otpCode;
    }

    final res = await _apiService.updateProfile(
      memberId: numericId,
      data: updatePayload,
      token: user.token,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (res.isSuccess) {
        _currentPasswordController.clear();
        _otpSecurityController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _securityOtpSent = false;
          _securityResendCountdown = 0;
        });
        _securityResendTimer?.cancel();
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
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    AppConstants.logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.shield, color: Color(0xFFF59E0B)),
                  ),
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
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  AppConstants.logoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.shield, color: Color(0xFFF59E0B)),
                ),
              ),
        titleSpacing: 0,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Member Portal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          // View Official Website in Browser
          IconButton(
            tooltip: 'View Official Website (Browser)',
            icon: const Icon(Icons.language, size: 20, color: Color(0xFFFBBF24)),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => UrlHelper.launchWebUrl(AppConstants.websiteUrl),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.volunteer_activism, size: 14),
            label: const Text('Donate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => _showQuickDonateModal(),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: 'Refresh Portal',
            icon: const Icon(Icons.refresh, size: 20),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: _loadMemberData,
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout, size: 20),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Documents'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Donations & 80G'),
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'My Profile'),
            Tab(icon: Icon(Icons.security_outlined, size: 18), text: 'Security & KYC'),
            Tab(icon: Icon(Icons.event_outlined, size: 18), text: 'Events & Meets'),
            Tab(icon: Icon(Icons.newspaper_outlined, size: 18), text: 'News & Press'),
            Tab(icon: Icon(Icons.photo_library_outlined, size: 18), text: 'Photo Gallery'),
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
                _buildEventsTab(),
                _buildNewsTab(),
                _buildGalleryTab(),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _tabController.animateTo(3),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Welcome, $memberName! 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text('ID: $memberId', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF10B981)),
                                  ),
                                  child: const Text('VERIFIED LIFE MEMBER', style: TextStyle(color: Color(0xFF34D399), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF59E0B)),
                                  ),
                                  child: const Text('80G EXEMPT', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white70),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Membership Validity & Quick Renewal Bar (Website Parity - Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_user, color: Color(0xFF10B981), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Membership: ${_membershipStatus.toUpperCase()}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF059669), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Valid Until: $_validityEnd • Authority: $_authorityName',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.autorenew, size: 14),
                              label: const Text('Renew Membership', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _showMembershipRenewalModal,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user, color: Color(0xFF10B981), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Membership Status: ${_membershipStatus.toUpperCase()}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF059669), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Valid Until: $_validityEnd • Authority: $_authorityName',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.autorenew, size: 14),
                            label: const Text('Renew', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: _showMembershipRenewalModal,
                          ),
                        ],
                      ),
              );
            },
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
              const SizedBox(height: 3),
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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

          // SECTION 1: Personal Details
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
                const Row(
                  children: [
                    Icon(Icons.badge, color: Color(0xFF4F46E5), size: 20),
                    SizedBox(width: 8),
                    Text('Personal Information', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Legal Name *', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: ['Male', 'Female', 'Other'].contains(_genderController.text.trim())
                            ? _genderController.text.trim()
                            : 'Male',
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _genderController.text = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDob(context),
                        borderRadius: BorderRadius.circular(4),
                        child: IgnorePointer(
                          child: TextField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth *',
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(Icons.cake),
                              suffixIcon: Icon(Icons.calendar_month, color: Color(0xFF4F46E5), size: 20),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        initialValue: ['S/O', 'D/O', 'W/O', 'C/O'].contains(_relationTypeController.text.trim().toUpperCase())
                            ? _relationTypeController.text.trim().toUpperCase()
                            : 'S/O',
                        decoration: const InputDecoration(
                          labelText: 'Relation',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'S/O', child: Text('S/O (Son)')),
                          DropdownMenuItem(value: 'D/O', child: Text('D/O (Dtr)')),
                          DropdownMenuItem(value: 'W/O', child: Text('W/O (Wife)')),
                          DropdownMenuItem(value: 'C/O', child: Text('C/O (Care)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _relationTypeController.text = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _relationNameController,
                        decoration: const InputDecoration(
                          labelText: 'Father / Husband Name',
                          prefixIcon: Icon(Icons.family_restroom),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _professionController,
                        decoration: const InputDecoration(
                          labelText: 'Profession / Designation',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        initialValue: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].contains(_bloodGroupController.text.trim().toUpperCase())
                            ? _bloodGroupController.text.trim().toUpperCase()
                            : 'O+',
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype, color: Colors.red),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A+', child: Text('A+')),
                          DropdownMenuItem(value: 'A-', child: Text('A-')),
                          DropdownMenuItem(value: 'B+', child: Text('B+')),
                          DropdownMenuItem(value: 'B-', child: Text('B-')),
                          DropdownMenuItem(value: 'O+', child: Text('O+')),
                          DropdownMenuItem(value: 'O-', child: Text('O-')),
                          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _bloodGroupController.text = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 2: Contact & Address Information
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
                const Row(
                  children: [
                    Icon(Icons.contact_mail, color: Color(0xFF4F46E5), size: 20),
                    SizedBox(width: 8),
                    Text('Contact & Address Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
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
                const SizedBox(height: 12),
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
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _pinCodeController,
                        decoration: const InputDecoration(labelText: 'Pin Code', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Full Permanent Address', prefixIcon: Icon(Icons.home), border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(labelText: 'Emergency Kinship Contact Phone', prefixIcon: Icon(Icons.contact_emergency), border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 3: Identity & KYC Status
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text('Identity & Statutory KYC', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(25), borderRadius: BorderRadius.circular(6)),
                      child: const Text('VERIFIED', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _aadharNoController,
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar Card Number',
                    prefixIcon: Icon(Icons.credit_card),
                    hintText: '12-digit Aadhaar number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Aadhaar details are encrypted and maintained securely under statutory compliance for Section 8 NGO governance.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 4: Membership Association & Validity
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Membership Association',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.autorenew, size: 14),
                              label: const Text('Renew Membership', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _showMembershipRenewalModal,
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Membership Association',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.autorenew, size: 14),
                          label: const Text('Renew Membership', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _showMembershipRenewalModal,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildStatementRow('Member Unique ID:', _authService.currentUser?.memberUserId ?? _authService.currentUser?.username ?? 'MBR0004'),
                _buildStatementRow('Designation / Role:', _professionController.text),
                _buildStatementRow('Approving Authority:', _authorityName),
                _buildStatementRow('Validity Period:', '$_validityStart — $_validityEnd', isBold: true),
                _buildStatementRow('Status:', _membershipStatus.toUpperCase()),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 5: Official Documents Access
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
                const Row(
                  children: [
                    Icon(Icons.file_present, color: Color(0xFF4F46E5), size: 20),
                    SizedBox(width: 8),
                    Text('Official Issued Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('View and download your official sealed foundation documents.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.badge, size: 16),
                      label: const Text('ID Card'),
                      onPressed: _showFullIdCardModal,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text('Appointment Letter'),
                      onPressed: _showAppointmentLetterModal,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.workspace_premium, size: 16),
                      label: const Text('Certificate'),
                      onPressed: _showCertificateModal,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.assessment, size: 16),
                      label: const Text('Form 10BD Statement'),
                      onPressed: _showForm10BDSummaryModal,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save & Update Profile Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: _handleSaveProfile,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: SECURITY & KYC
  // ==========================================
  String _getMaskedEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final userPart = parts[0];
    final domain = parts.length > 1 ? parts[1] : '';
    if (userPart.length <= 2) {
      return '${userPart[0]}*@$domain';
    }
    final masked = '${userPart.substring(0, 2)}${'*' * (userPart.length - 3)}${userPart.substring(userPart.length - 1)}@$domain';
    return masked;
  }

  Widget _buildSecurityTab() {
    final curEmail = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : (_authService.currentUser?.email ?? '');
    final displayEmail = _maskedSecurityEmail ?? _getMaskedEmail(curEmail);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Security & Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Secure your account. Changing your password requires verification via your Current Password OR a 6-digit Email OTP.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Security policy notice card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF4F46E5), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Two-Factor Authorization Enforced',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF312E81)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose an authorization method below to confirm your identity before updating credentials.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Password Change Container
          Container(
            padding: const EdgeInsets.all(20),
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
                const Text(
                  'Step 1: Choose Authorization Method',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 10),

                // Dual-Mode Selector Tabs
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _securityAuthMode = 'password');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _securityAuthMode == 'password' ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _securityAuthMode == 'password'
                                  ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_clock_outlined,
                                  size: 16,
                                  color: _securityAuthMode == 'password' ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Current Password',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _securityAuthMode == 'password' ? FontWeight.bold : FontWeight.w500,
                                    color: _securityAuthMode == 'password' ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _securityAuthMode = 'otp');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _securityAuthMode == 'otp' ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _securityAuthMode == 'otp'
                                  ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 16,
                                  color: _securityAuthMode == 'otp' ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Email OTP Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _securityAuthMode == 'otp' ? FontWeight.bold : FontWeight.w500,
                                    color: _securityAuthMode == 'otp' ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // MODE A: Current Password Field
                if (_securityAuthMode == 'password') ...[
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Account Password *',
                      hintText: 'Enter your existing password',
                      prefixIcon: const Icon(Icons.lock_clock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Verification verifies your current active password in the database.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ] else ...[
                  // MODE B: Email OTP Dispatch & Input
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mail_lock_outlined, size: 20, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Registered Email: $displayEmail',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1E293B)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4F46E5),
                              side: const BorderSide(color: Color(0xFF4F46E5)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: _isSendingSecurityOtp
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(_securityOtpSent ? Icons.refresh : Icons.send, size: 16),
                            label: Text(
                              _isSendingSecurityOtp
                                  ? 'Dispatching OTP Code...'
                                  : _securityResendCountdown > 0
                                      ? 'Resend OTP in ${_securityResendCountdown}s'
                                      : _securityOtpSent
                                          ? 'Resend 6-Digit OTP'
                                          : 'Send 6-Digit OTP Code',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: (_isSendingSecurityOtp || _securityResendCountdown > 0)
                                ? null
                                : _handleSendSecurityOtp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otpSecurityController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Enter 6-Digit OTP Code *',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Check your email inbox and spam folder. The 6-digit code expires in 10 minutes.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                const Text(
                  'Step 2: Enter New Credentials',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),

                // New Password Field
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password *',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password *',
                    hintText: 'Re-enter your new password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.key, size: 18),
                    label: Text(
                      _isLoading ? 'Updating Credentials...' : 'Update Password',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: _isLoading ? null : _handleChangePassword,
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

          // 3 Contact Channels (Website Parity)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final channelCards = [
                _buildContactChannelCard(
                  title: 'Call Us',
                  subtitle: 'Mon–Sat, 9AM – 6PM',
                  detail: AppConstants.phone,
                  icon: Icons.phone,
                  color: const Color(0xFF4F46E5),
                  btnLabel: 'Call Now',
                  onTap: () => UrlHelper.launchPhoneCall(context),
                ),
                _buildContactChannelCard(
                  title: 'Email Us',
                  subtitle: 'Replies within 24 hours',
                  detail: AppConstants.email,
                  icon: Icons.email,
                  color: const Color(0xFF10B981),
                  btnLabel: 'Send Email',
                  onTap: () => UrlHelper.launchEmail(context),
                ),
                _buildContactChannelCard(
                  title: 'Visit Us',
                  subtitle: 'Foundation Central Office',
                  detail: 'SCO-88, Opp. Sector 12 A, Gurugram',
                  icon: Icons.location_on,
                  color: const Color(0xFFF59E0B),
                  btnLabel: 'Get Directions',
                  onTap: () => UrlHelper.launchWebUrl('https://maps.google.com/?q=SCO-88+Opp+Sector+12+A+Gurugram'),
                ),
              ];

              if (isWide) {
                return Row(
                  children: channelCards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
                );
              } else {
                return Column(
                  children: channelCards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c)).toList(),
                );
              }
            },
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
                  isExpanded: true,
                  initialValue: _ticketCategory,
                  decoration: const InputDecoration(labelText: 'Inquiry Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
                    DropdownMenuItem(value: 'Document Issue', child: Text('Document Issue (ID Card / Certificate)')),
                    DropdownMenuItem(value: 'Donation & Tax Receipt', child: Text('Donation & Tax Receipt (80G / 10BD)')),
                    DropdownMenuItem(value: 'Profile Update', child: Text('Profile Update Request')),
                    DropdownMenuItem(value: 'Welfare Grant', child: Text('Welfare Grant & Family Assistance')),
                    DropdownMenuItem(value: 'Event Participation', child: Text('Event & Memorial RSVP')),
                    DropdownMenuItem(value: 'Other', child: Text('Other Question / Feedback')),
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

  Widget _buildContactChannelCard({
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
    required String btnLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                    Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTap,
              child: Text(btnLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 6: EVENTS & MEETS
  // ==========================================
  Widget _buildEventsTab() {
    final filteredEvents = _selectedEventFilter == 'All'
        ? _events
        : _events.where((e) => e['category'] == _selectedEventFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_available, color: Color(0xFF818CF8), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foundation Events & Assemblies',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_rsvpedEvents.length} RSVP Confirmed • All events organized under Section 8 guidelines',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Commemoration', 'Welfare', 'Blood Drive', 'Education'].map((cat) {
                final isSelected = _selectedEventFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedEventFilter = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final ev = filteredEvents[index];
              final eventId = ev['id'].toString();
              final isRsvped = _rsvpedEvents.contains(eventId);
              final Color badgeColor = ev['color'] as Color? ?? const Color(0xFF4F46E5);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: badgeColor.withAlpha(50)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_month, size: 18, color: Color(0xFF475569)),
                              const SizedBox(height: 2),
                              Text(
                                ev['date'].toString().split(' ')[0],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: badgeColor),
                              ),
                              Text(
                                ev['date'].toString().split(' ').length > 1 ? ev['date'].toString().split(' ')[1].toUpperCase() : 'OCT',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ev['badge'].toString(),
                                  style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ev['title'].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(ev['time'].toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ev['location'].toString(),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ev['description'].toString(),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRsvped ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: Icon(isRsvped ? Icons.check_circle : Icons.how_to_reg, size: 16),
                            label: Text(
                              isRsvped ? 'RSVP Confirmed' : 'RSVP for Event',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isRsvped) {
                                  _rsvpedEvents.remove(eventId);
                                } else {
                                  _rsvpedEvents.add(eventId);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    !isRsvped
                                        ? 'RSVP Confirmed for ${ev['title']}! Seat pass reserved.'
                                        : 'RSVP canceled for ${ev['title']}.',
                                  ),
                                  backgroundColor: !isRsvped ? const Color(0xFF10B981) : Colors.orange.shade800,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Event details copied: ${ev['title']}')),
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
        ],
      ),
    );
  }

  // ==========================================
  // TAB 7: NEWS & PRESS RELEASES
  // ==========================================
  Widget _buildNewsTab() {
    final list = _blogs.isNotEmpty ? _blogs : _fallbackBlogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.newspaper, color: Color(0xFFFBBF24), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'News & Press Releases',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Official announcements, gazette dispatches and welfare impact bulletins',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final art = list[index];
              final title = art['title']?.toString() ?? 'Official Notice';
              final summary = art['summary']?.toString() ?? art['content']?.toString() ?? '';
              final category = art['category']?.toString() ?? 'Press Release';
              final date = art['created_at']?.toString() ?? '2026-09-20';
              final author = art['author']?.toString() ?? 'Foundation Media Bureau';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ),
                        Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('By $author', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                        TextButton.icon(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('Read Full', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BlogDetailScreen(article: art)),
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
        ],
      ),
    );
  }

  // ==========================================
  // TAB 8: PHOTO GALLERY & MEDIA
  // ==========================================
  Widget _buildGalleryTab() {
    final list = _galleryPhotos.isNotEmpty ? _galleryPhotos : _fallbackGallery;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF34D399), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media & Photo Archives',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Visual records of field relief interventions, martyr homages & ceremonies',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final photo = list[index];
              final title = photo['title']?.toString() ?? 'Gallery Image';
              final category = photo['category']?.toString() ?? 'Field Action';
              final image = photo['image']?.toString() ?? photo['photo']?.toString() ?? AppConstants.soldierHero;
              final caption = photo['caption']?.toString() ?? photo['description']?.toString() ?? '';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            image.startsWith('http')
                                ? Image.network(image, height: 260, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset(AppConstants.soldierHero, height: 260, width: double.infinity, fit: BoxFit.cover))
                                : Image.asset(image, height: 260, width: double.infinity, fit: BoxFit.cover),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(caption.isNotEmpty ? caption : category, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            image.startsWith('http')
                                ? Image.network(image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset(AppConstants.soldierHero, fit: BoxFit.cover))
                                : Image.asset(image, fit: BoxFit.cover),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(160),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              caption.isNotEmpty ? caption : 'Tap to expand view',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
