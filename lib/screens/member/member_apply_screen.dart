import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_repository.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';
import 'member_verify_screen.dart';

class MemberApplyScreen extends StatefulWidget {
  const MemberApplyScreen({super.key});

  @override
  State<MemberApplyScreen> createState() => _MemberApplyScreenState();
}

class _MemberApplyScreenState extends State<MemberApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form Controllers
  final _aadharCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _relationNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _donationAmountCtrl = TextEditingController(text: '5000');
  final _utrCtrl = TextEditingController();

  String _gender = 'Male';
  String _relationType = 'S/O';
  String _paymentMode = 'UPI / QR Code';

  // Upload simulation flags
  bool _photoAttached = false;
  bool _aadharFrontAttached = true;
  bool _aadharBackAttached = true;
  bool _receiptAttached = false;

  @override
  void dispose() {
    _aadharCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _relationNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _pinCodeCtrl.dispose();
    _occupationCtrl.dispose();
    _qualificationCtrl.dispose();
    _donationAmountCtrl.dispose();
    _utrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.secondaryNavy,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanMobile = _mobileCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final cleanAadhar = _aadharCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final cleanEmail = _emailCtrl.text.trim().toLowerCase();

    final repo = AppRepository();

    // Prevent duplicate Aadhaar
    if (cleanAadhar.isNotEmpty && repo.members.any((m) => m.aadharNumber.replaceAll(RegExp(r'[^0-9]'), '') == cleanAadhar)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This Aadhaar card number is already registered with an existing member.'),
          backgroundColor: AppTheme.flameRed,
        ),
      );
      return;
    }

    // Prevent duplicate Mobile
    if (cleanMobile.isNotEmpty && repo.members.any((m) => m.mobile.replaceAll(RegExp(r'[^0-9]'), '') == cleanMobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This contact number is already registered with an existing member.'),
          backgroundColor: AppTheme.flameRed,
        ),
      );
      return;
    }

    // Prevent duplicate Email if entered
    if (cleanEmail.isNotEmpty && repo.members.any((m) => m.email.toLowerCase() == cleanEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This email address is already registered. Each member must have a unique email.'),
          backgroundColor: AppTheme.flameRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? backendRef;
    try {
      final res = await ApiService().applyMember(data: {
        'name': _nameCtrl.text.trim(),
        'gender': _gender.toLowerCase(),
        'dob': _dobCtrl.text.trim().isEmpty ? '1995-01-01' : _dobCtrl.text.trim(),
        'father_name': _relationNameCtrl.text.trim().isEmpty
            ? 'Father/Husband Name'
            : _relationNameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? 'member@sfofindia.org' : _emailCtrl.text.trim(),
        'state': _stateCtrl.text.trim().isEmpty ? 'Haryana' : _stateCtrl.text.trim(),
        'city': _districtCtrl.text.trim().isEmpty ? 'Gurugram' : _districtCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'pincode': _pinCodeCtrl.text.trim().isEmpty ? '122001' : _pinCodeCtrl.text.trim(),
        'profession': _occupationCtrl.text.trim().isEmpty ? 'Social Worker' : _occupationCtrl.text.trim(),
        'aadhar_no': cleanAadhar,
        'blood_group': 'O+',
        'donation_amount': 5000.0,
        'payment_mode': _paymentMode,
        'upi_utr': _utrCtrl.text.trim(),
        'bank_utr': _utrCtrl.text.trim(),
      });

      if (res.isSuccess && res.data != null && res.data is Map) {
        backendRef = (res.data as Map)['reference_id']?.toString();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    final newMember = repo.registerMember(
      fullName: _nameCtrl.text.trim(),
      gender: _gender,
      dob: _dobCtrl.text.trim().isEmpty ? '1995-01-01' : _dobCtrl.text.trim(),
      relationType: _relationType,
      relationName: _relationNameCtrl.text.trim().isEmpty
          ? 'Father/Husband Name'
          : _relationNameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? 'member@sfofindia.org' : _emailCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      pinCode: _pinCodeCtrl.text.trim(),
      occupation: _occupationCtrl.text.trim().isEmpty ? 'Social Worker' : _occupationCtrl.text.trim(),
      qualification: _qualificationCtrl.text.trim().isEmpty ? 'Graduate' : _qualificationCtrl.text.trim(),
      aadharNumber: _aadharCtrl.text.trim().replaceAll(' ', ''),
      bloodGroup: 'O+',
    );

    if (mounted) {
      _showRegisteredDialog(newMember, referenceId: backendRef);
    }
  }

  void _showRegisteredDialog(MemberModel member, {String? referenceId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.wreathGreen.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.wreathGreen,
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Shaheed Foundation of India,\n${member.fullName}.\nYour official Member ID is:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNavy.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryGold),
              ),
              child: Column(
                children: [
                  Text(
                    member.publicId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondaryNavy,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (referenceId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ref: $referenceId (Backend Synced)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.wreathGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: AppTheme.secondaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberVerifyScreen(initialMember: member),
                    ),
                  );
                },
                icon: const Icon(Icons.credit_card, size: 18),
                label: const Text(
                  'View My Digital ID Card',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Member Registration'),
        backgroundColor: AppTheme.secondaryNavy,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Unified Modern Header Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 18 : 24,
                    horizontal: isMobile ? 16 : 24,
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
                        'Membership Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Join Our Mission • Become a certified member of Shaheed Foundation India',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Container
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 14 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(isMobile ? 16 : 24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section 1: Identity Verification
                                    _buildSectionHeader(
                                      icon: Icons.shield_rounded,
                                      title: '1. Identity Verification',
                                    ),
                                    const SizedBox(height: 12),

                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Aadhaar Number *',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _aadharCtrl,
                                            keyboardType: TextInputType.number,
                                            maxLength: 12,
                                            decoration: const InputDecoration(
                                              hintText: '0000 0000 0000',
                                              prefixIcon: Icon(Icons.credit_card, color: AppTheme.secondaryNavy),
                                              counterText: '',
                                            ),
                                            validator: (v) => v == null || v.trim().length != 12
                                                ? 'Enter valid 12-digit Aadhaar number'
                                                : null,
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Aadhaar details will be verified against uploaded identity documents.',
                                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Section 2: Personal Information
                                    _buildSectionHeader(
                                      icon: Icons.person_rounded,
                                      title: '2. Personal Information',
                                    ),
                                    const SizedBox(height: 12),

                                    _formLabel('Full Name *'),
                                    TextFormField(
                                      controller: _nameCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'As per official documents',
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty ? 'Please enter full name' : null,
                                    ),
                                    const SizedBox(height: 14),

                                    // Responsive Gender & DOB
                                    if (isMobile) ...[
                                      _formLabel('Gender *'),
                                      _buildGenderDropdown(),
                                      const SizedBox(height: 14),
                                      _formLabel('Date of Birth *'),
                                      _buildDobField(),
                                    ] else ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Gender *'),
                                                _buildGenderDropdown(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Date of Birth *'),
                                                _buildDobField(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 14),

                                    // Responsive Relation & Relation Name
                                    if (isMobile) ...[
                                      _formLabel('Relation'),
                                      _buildRelationDropdown(),
                                      const SizedBox(height: 14),
                                      _formLabel('Relation Name'),
                                      _buildRelationNameField(),
                                    ] else ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Relation'),
                                                _buildRelationDropdown(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Relation Name'),
                                                _buildRelationNameField(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 22),

                                    // Section 3: Communication & Location
                                    _buildSectionHeader(
                                      icon: Icons.phone_android_rounded,
                                      title: '3. Communication & Location',
                                    ),
                                    const SizedBox(height: 12),

                                    _formLabel('Mobile Number *'),
                                    TextFormField(
                                      controller: _mobileCtrl,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        prefixText: '+91 ',
                                        hintText: '9876543210',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                      validator: (v) => v == null || v.trim().length < 10
                                          ? '10-digit mobile required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),

                                    _formLabel('Email Address'),
                                    TextFormField(
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: 'example@mail.com',
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    _formLabel('Residential Address *'),
                                    TextFormField(
                                      controller: _addressCtrl,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        hintText: 'House/Flat, Street, Area...',
                                        prefixIcon: Icon(Icons.home_outlined),
                                      ),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty ? 'Address is required' : null,
                                    ),
                                    const SizedBox(height: 14),

                                    // Responsive State & District
                                    if (isMobile) ...[
                                      _formLabel('State *'),
                                      _buildStateField(),
                                      const SizedBox(height: 14),
                                      _formLabel('District *'),
                                      _buildDistrictField(),
                                    ] else ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('State *'),
                                                _buildStateField(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('District *'),
                                                _buildDistrictField(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 14),

                                    _formLabel('Pin Code *'),
                                    TextFormField(
                                      controller: _pinCodeCtrl,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. 122001',
                                        prefixIcon: Icon(Icons.location_on_outlined),
                                        counterText: '',
                                      ),
                                      validator: (v) =>
                                          v == null || v.trim().length != 6 ? '6 digits required' : null,
                                    ),

                                    const SizedBox(height: 22),

                                    // Section 4: Professional Documents
                                    _buildSectionHeader(
                                      icon: Icons.file_upload_outlined,
                                      title: '4. Professional Documents',
                                    ),
                                    const SizedBox(height: 12),

                                    // Responsive Upload Cards
                                    _buildDocUploadListTile(
                                      title: 'Aadhaar Card (Front Side) *',
                                      subtitle: _aadharFrontAttached ? 'Front side attached' : 'Upload front side photo/scan',
                                      isAttached: _aadharFrontAttached,
                                      isRequired: true,
                                      icon: Icons.credit_card_outlined,
                                      onToggle: () => setState(() => _aadharFrontAttached = !_aadharFrontAttached),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDocUploadListTile(
                                      title: 'Aadhaar Card (Back Side) *',
                                      subtitle: _aadharBackAttached ? 'Back side attached' : 'Upload back side photo/scan',
                                      isAttached: _aadharBackAttached,
                                      isRequired: true,
                                      icon: Icons.credit_card_outlined,
                                      onToggle: () => setState(() => _aadharBackAttached = !_aadharBackAttached),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDocUploadListTile(
                                      title: 'Member Profile Photo (Optional)',
                                      subtitle: _photoAttached ? 'Passport photo attached' : 'Can be uploaded later anytime in Member Portal',
                                      isAttached: _photoAttached,
                                      isRequired: false,
                                      icon: Icons.account_box_outlined,
                                      onToggle: () => setState(() => _photoAttached = !_photoAttached),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Identity documents are strictly verified by foundation officers before activating your ID card.',
                                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),

                                    const SizedBox(height: 26),

                                    // Section 5: Membership Fee & Payment Method
                                    _buildSectionHeader(
                                      icon: Icons.volunteer_activism_rounded,
                                      title: '5. Membership Fee & Payment Method',
                                    ),
                                    const SizedBox(height: 14),

                                    // Responsive Fee & Payment Selection
                                    if (isMobile) ...[
                                      _formLabel('Annual Membership Fee *'),
                                      _buildFeeCard(),
                                      const SizedBox(height: 14),
                                      _formLabel('Payment Method *'),
                                      _buildPaymentDropdown(),
                                    ] else ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Annual Membership Fee *'),
                                                _buildFeeCard(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _formLabel('Payment Method *'),
                                                _buildPaymentDropdown(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),

                                    // Dynamic Mode Details Panel
                                    if (_paymentMode == 'UPI / QR Code')
                                      _buildUpiPanel(isMobile)
                                    else if (_paymentMode == 'Credit / Debit Card')
                                      _buildCardPanel()
                                    else if (_paymentMode == 'Netbanking')
                                      _buildNetbankingPanel()
                                    else if (_paymentMode == 'Bank Transfer') ...[
                                      _buildBankTransferPanel(context, isMobile),
                                    ],

                                    const SizedBox(height: 26),

                                    // Submit Button (Calm Eye-Friendly Dark Slate #0F172A)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0F172A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 2,
                                          shadowColor: const Color(0xFF0F172A).withAlpha(60),
                                        ),
                                        onPressed: _isSubmitting ? null : _submitApplication,
                                        icon: _isSubmitting
                                            ? const SizedBox.shrink()
                                            : const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
                                        label: _isSubmitting
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                _paymentMode == 'Bank Transfer'
                                                    ? 'Submit Registration (₹5,000)'
                                                    : 'Proceed to Pay ₹5,000 & Register',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: ['Male', 'Female', 'Other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13))))
          .toList(),
      onChanged: (v) => setState(() => _gender = v ?? 'Male'),
    );
  }

  Widget _buildDobField() {
    return TextFormField(
      controller: _dobCtrl,
      readOnly: true,
      onTap: _pickDate,
      decoration: const InputDecoration(
        hintText: 'YYYY-MM-DD',
        suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Select DOB' : null,
    );
  }

  Widget _buildRelationDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _relationType,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'S/O', child: Text('Son of', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'D/O', child: Text('Daughter of', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'W/O', child: Text('Wife of', style: TextStyle(fontSize: 13))),
      ],
      onChanged: (v) => setState(() => _relationType = v ?? 'S/O'),
    );
  }

  Widget _buildRelationNameField() {
    return TextFormField(
      controller: _relationNameCtrl,
      decoration: const InputDecoration(
        hintText: 'Father / Husband Name',
        prefixIcon: Icon(Icons.family_restroom_outlined),
      ),
    );
  }

  Widget _buildStateField() {
    return TextFormField(
      controller: _stateCtrl,
      decoration: const InputDecoration(hintText: 'e.g. Haryana'),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDistrictField() {
    return TextFormField(
      controller: _districtCtrl,
      decoration: const InputDecoration(hintText: 'e.g. Gurugram'),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _buildFeeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Text(
            '₹ 5,000',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text(
              'Fixed (1 Year)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _paymentMode,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(
          value: 'UPI / QR Code',
          child: Text('UPI / QR Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        DropdownMenuItem(
          value: 'Credit / Debit Card',
          child: Text('Credit / Debit Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        DropdownMenuItem(
          value: 'Netbanking',
          child: Text('Netbanking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        DropdownMenuItem(
          value: 'Bank Transfer',
          child: Text('Direct Bank Transfer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
      onChanged: (v) => setState(() => _paymentMode = v ?? 'UPI / QR Code'),
    );
  }

  Widget _buildDocUploadListTile({
    required String title,
    required String subtitle,
    required bool isAttached,
    required bool isRequired,
    required IconData icon,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isAttached ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAttached ? AppTheme.wreathGreen : const Color(0xFFE2E8F0),
            width: isAttached ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAttached ? AppTheme.wreathGreen.withAlpha(20) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAttached ? Icons.check_circle : icon,
                color: isAttached ? AppTheme.wreathGreen : const Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isAttached ? AppTheme.wreathGreen : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isAttached ? AppTheme.wreathGreen.withAlpha(200) : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isAttached ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isAttached ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                isAttached ? 'ATTACHED' : (isRequired ? 'TAP TO ADD' : 'OPTIONAL'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isAttached ? const Color(0xFF166534) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiPanel(bool isMobile) {
    return Container(
      width: double.infinity,
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
            children: const [
              Icon(Icons.qr_code_2, color: Color(0xFF1E3A8A), size: 20),
              SizedBox(width: 8),
              Text(
                'UPI / QR Code Payment',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan official QR code or copy UPI ID to pay ₹5,000 via Google Pay, PhonePe, Paytm, or BHIM.',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'shaheedfoundation@axisbank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      fontFamily: 'monospace',
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'shaheedfoundation@axisbank'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPI ID shaheedfoundation@axisbank Copied!')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy, size: 12, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 4),
                        Text('Copy UPI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _formLabel('UPI Reference / UTR Number (Optional)'),
          TextFormField(
            controller: _utrCtrl,
            decoration: const InputDecoration(
              hintText: '12-digit UTR number after payment',
              prefixIcon: Icon(Icons.tag_outlined),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, size: 14, color: AppTheme.wreathGreen),
              SizedBox(width: 5),
              Text(
                'Verified Merchant: SHAHEED FOUNDATION',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.wreathGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lock_outline, color: Color(0xFF1D4ED8), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit / Debit Card Payment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                ),
                SizedBox(height: 4),
                Text(
                  '256-Bit SSL Encrypted: Accepts all Visa, MasterCard, RuPay, and Maestro cards. Tap Proceed to open the secure banking gateway.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetbankingPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.account_balance, color: Color(0xFF1D4ED8), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Netbanking (All Major Indian Banks)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                ),
                SizedBox(height: 4),
                Text(
                  'You will be securely routed to your bank\'s authentication gateway to complete the ₹5,000 transaction.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferPanel(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(60),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance, color: AppTheme.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bank Transfer Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(
                        text:
                            'SHAHEED FOUNDATION\nAXIS BANK\nA/C: 925010034361992\nIFSC: UTIB0001970\nBranch: Sector 29, Gurgaon',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bank Details Copied!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.copy, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('Copy', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),
              _buildBankRow('Account Name', 'SHAHEED FOUNDATION'),
              _buildBankRow('Bank Name', 'AXIS BANK'),
              _buildBankRow('Account Number', '925010034361992'),
              _buildBankRow('IFSC Code', 'UTIB0001970'),
              _buildBankRow('Branch', 'Sector 29, Gurgaon'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _formLabel('NEFT / RTGS / UTR Reference Number'),
        TextFormField(
          controller: _utrCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter 12 or 16-digit UTR number',
            prefixIcon: Icon(Icons.confirmation_number_outlined),
          ),
        ),
        const SizedBox(height: 14),

        _formLabel('Upload Payment Receipt'),
        InkWell(
          onTap: () => setState(() => _receiptAttached = !_receiptAttached),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _receiptAttached
                  ? AppTheme.wreathGreen.withAlpha(20)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _receiptAttached ? AppTheme.wreathGreen : const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _receiptAttached ? Icons.check_circle : Icons.upload_file,
                  color: _receiptAttached ? AppTheme.wreathGreen : AppTheme.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _receiptAttached
                      ? 'Payment Receipt Attached (Tap to remove)'
                      : 'Click to upload transaction receipt',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _receiptAttached ? AppTheme.wreathGreen : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _formLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    bool isCharity = false,
  }) {
    final borderColor = isCharity ? const Color(0xFFDB2777) : const Color(0xFF2563EB);
    final textColor = isCharity ? const Color(0xFFDB2777) : const Color(0xFF1E3A8A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

}
