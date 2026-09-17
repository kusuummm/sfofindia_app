import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

enum DocumentType {
  idCard,
  appointmentLetter,
  certificate,
  taxReceipt80G,
}

class DocumentPreviewDialog extends StatefulWidget {
  final DocumentType type;
  final String memberName;
  final String memberId;
  final String? memberPhone;
  final String? memberEmail;
  final String? memberCategory;
  final String? memberState;
  final String? memberDistrict;
  final String? issueDate;
  final double? donationAmount;

  // Customizable document template fields
  final String? designation;
  final String? validUntil;
  final String? bloodGroup;
  final String? refNumber;
  final String? letterSubject;
  final String? bodyText;
  final String? certificateTitle;
  final String? subTitle;
  final String? signatoryName;
  final String? signatoryTitle;
  final String? signatory2Name;
  final String? signatory2Title;
  final String? panNumber;
  final String? receiptNumber;
  final bool isEditable;
  final VoidCallback? onEdit;
  final void Function(Map<String, dynamic> updatedData)? onSave;

  const DocumentPreviewDialog({
    super.key,
    required this.type,
    required this.memberName,
    required this.memberId,
    this.memberPhone,
    this.memberEmail,
    this.memberCategory = 'Life Welfare Member',
    this.memberState = 'Haryana',
    this.memberDistrict = 'Gurugram',
    this.issueDate,
    this.donationAmount,
    this.designation,
    this.validUntil,
    this.bloodGroup,
    this.refNumber,
    this.letterSubject,
    this.bodyText,
    this.certificateTitle,
    this.subTitle,
    this.signatoryName,
    this.signatoryTitle,
    this.signatory2Name,
    this.signatory2Title,
    this.panNumber,
    this.receiptNumber,
    this.isEditable = true,
    this.onEdit,
    this.onSave,
  });

  static void show(
    BuildContext context, {
    required DocumentType type,
    required String memberName,
    required String memberId,
    String? memberPhone,
    String? memberEmail,
    String? memberCategory,
    String? memberState,
    String? memberDistrict,
    String? issueDate,
    double? donationAmount,
    String? designation,
    String? validUntil,
    String? bloodGroup,
    String? refNumber,
    String? letterSubject,
    String? bodyText,
    String? certificateTitle,
    String? subTitle,
    String? signatoryName,
    String? signatoryTitle,
    String? signatory2Name,
    String? signatory2Title,
    String? panNumber,
    String? receiptNumber,
    bool isEditable = true,
    VoidCallback? onEdit,
    void Function(Map<String, dynamic> updatedData)? onSave,
  }) {
    showDialog(
      context: context,
      builder: (_) => DocumentPreviewDialog(
        type: type,
        memberName: memberName,
        memberId: memberId,
        memberPhone: memberPhone,
        memberEmail: memberEmail,
        memberCategory: memberCategory,
        memberState: memberState,
        memberDistrict: memberDistrict,
        issueDate: issueDate,
        donationAmount: donationAmount,
        designation: designation,
        validUntil: validUntil,
        bloodGroup: bloodGroup,
        refNumber: refNumber,
        letterSubject: letterSubject,
        bodyText: bodyText,
        certificateTitle: certificateTitle,
        subTitle: subTitle,
        signatoryName: signatoryName,
        signatoryTitle: signatoryTitle,
        signatory2Name: signatory2Name,
        signatory2Title: signatory2Title,
        panNumber: panNumber,
        receiptNumber: receiptNumber,
        isEditable: isEditable,
        onEdit: onEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<DocumentPreviewDialog> createState() => _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends State<DocumentPreviewDialog> {
  bool _isEditing = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _validUntilCtrl;
  late TextEditingController _bloodGroupCtrl;
  late TextEditingController _refNumberCtrl;
  late TextEditingController _letterSubjectCtrl;
  late TextEditingController _bodyTextCtrl;
  late TextEditingController _certTitleCtrl;
  late TextEditingController _subTitleCtrl;
  late TextEditingController _signatoryNameCtrl;
  late TextEditingController _signatoryTitleCtrl;
  late TextEditingController _issueDateCtrl;
  late TextEditingController _panCtrl;
  late TextEditingController _receiptCtrl;
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final defaultDate = widget.issueDate ?? DateTime.now().toString().substring(0, 10);
    final effectiveRole = widget.designation ?? widget.memberCategory ?? 'Life Welfare Member';

    String defaultBody = widget.bodyText ?? '';
    if (defaultBody.isEmpty) {
      if (widget.type == DocumentType.appointmentLetter) {
        defaultBody =
            'Dear ${widget.memberName},\n\nOn behalf of the National Executive Council of Shaheed Foundation of India, we are pleased to confirm your enrollment as a Registered Member in the category of "$effectiveRole".\n\nYour commitment to supporting the welfare of the families of our national martyrs and bravehearts is deeply valued. In this capacity, you are authorized to represent our collective mission and participate in national initiatives, memorial ceremonies, and family outreach programs.';
      } else if (widget.type == DocumentType.certificate) {
        defaultBody =
            'In sincere recognition and deep gratitude for your noble commitment, selfless contribution, and steadfast support extended to the families of India\'s brave martyrs.';
      }
    }

    _nameCtrl = TextEditingController(text: widget.memberName);
    _idCtrl = TextEditingController(text: widget.memberId);
    _phoneCtrl = TextEditingController(text: widget.memberPhone ?? '9876543210');
    _emailCtrl = TextEditingController(text: widget.memberEmail ?? 'member@shaheedfoundation.in');
    _categoryCtrl = TextEditingController(text: widget.memberCategory ?? 'Life Welfare Member');
    _stateCtrl = TextEditingController(text: widget.memberState ?? 'Haryana');
    _districtCtrl = TextEditingController(text: widget.memberDistrict ?? 'Gurugram');
    _designationCtrl = TextEditingController(text: effectiveRole);
    _validUntilCtrl = TextEditingController(text: widget.validUntil ?? 'Lifetime');
    _bloodGroupCtrl = TextEditingController(text: widget.bloodGroup ?? 'O+ve');
    _refNumberCtrl = TextEditingController(text: widget.refNumber ?? 'SFI/APPT/${DateTime.now().year}/${widget.memberId}');
    _letterSubjectCtrl = TextEditingController(text: widget.letterSubject ?? 'Subject: Official Letter of Membership & Association');
    _bodyTextCtrl = TextEditingController(text: defaultBody);
    _certTitleCtrl = TextEditingController(text: widget.certificateTitle ?? 'CERTIFICATE OF APPRECIATION');
    _subTitleCtrl = TextEditingController(text: widget.subTitle ?? 'This certificate is proudly awarded to');
    _signatoryNameCtrl = TextEditingController(text: widget.signatoryName ?? 'Col. Gurmeet Singh');
    _signatoryTitleCtrl = TextEditingController(text: widget.signatoryTitle ?? 'National Secretary\nShaheed Foundation of India');
    _issueDateCtrl = TextEditingController(text: defaultDate);
    _panCtrl = TextEditingController(text: widget.panNumber ?? 'AAECS8948K (Trustee)');
    _receiptCtrl = TextEditingController(text: widget.receiptNumber ?? 'RCP-80G-${DateTime.now().year}-${widget.memberId}');
    _amountCtrl = TextEditingController(text: (widget.donationAmount ?? 3500.0).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _categoryCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _designationCtrl.dispose();
    _validUntilCtrl.dispose();
    _bloodGroupCtrl.dispose();
    _refNumberCtrl.dispose();
    _letterSubjectCtrl.dispose();
    _bodyTextCtrl.dispose();
    _certTitleCtrl.dispose();
    _subTitleCtrl.dispose();
    _signatoryNameCtrl.dispose();
    _signatoryTitleCtrl.dispose();
    _issueDateCtrl.dispose();
    _panCtrl.dispose();
    _receiptCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case DocumentType.idCard:
        return 'Official Digital ID Card';
      case DocumentType.appointmentLetter:
        return 'Official Appointment Letter';
      case DocumentType.certificate:
        return _certTitleCtrl.text.isNotEmpty ? _certTitleCtrl.text : 'Certificate of Appreciation';
      case DocumentType.taxReceipt80G:
        return '80G Tax Exemption Receipt';
    }
  }

  Map<String, dynamic> _getDataMap() {
    return {
      'memberName': _nameCtrl.text,
      'memberId': _idCtrl.text,
      'memberPhone': _phoneCtrl.text,
      'memberEmail': _emailCtrl.text,
      'memberCategory': _categoryCtrl.text,
      'memberState': _stateCtrl.text,
      'memberDistrict': _districtCtrl.text,
      'designation': _designationCtrl.text,
      'validUntil': _validUntilCtrl.text,
      'bloodGroup': _bloodGroupCtrl.text,
      'refNumber': _refNumberCtrl.text,
      'letterSubject': _letterSubjectCtrl.text,
      'bodyText': _bodyTextCtrl.text,
      'certificateTitle': _certTitleCtrl.text,
      'subTitle': _subTitleCtrl.text,
      'signatoryName': _signatoryNameCtrl.text,
      'signatoryTitle': _signatoryTitleCtrl.text,
      'issueDate': _issueDateCtrl.text,
      'panNumber': _panCtrl.text,
      'receiptNumber': _receiptCtrl.text,
      'donationAmount': double.tryParse(_amountCtrl.text) ?? 3500.0,
    };
  }

  void _applyDialogPreset(String presetKey) {
    setState(() {
      final name = _nameCtrl.text;
      if (widget.type == DocumentType.appointmentLetter) {
        if (presetKey == 'district') {
          _designationCtrl.text = 'District Welfare Coordinator';
          _categoryCtrl.text = 'Executive Council Appointee';
          _letterSubjectCtrl.text = 'Subject: Appointment as Official District Welfare Coordinator';
          _validUntilCtrl.text = '31 Dec 2028';
          _bodyTextCtrl.text =
              'The National Executive Council of Shaheed Foundation of India is pleased to formally appoint you as District Welfare Coordinator for ${_districtCtrl.text}, ${_stateCtrl.text}.\n\nIn this executive capacity, you are empowered to oversee martyr family outreach, coordinate emergency welfare grants, and represent our national cause at regional defense commemorations.';
        } else if (presetKey == 'state') {
          _designationCtrl.text = 'State Executive Secretary';
          _categoryCtrl.text = 'State Governing Board';
          _letterSubjectCtrl.text = 'Subject: Appointment as State Executive Secretary';
          _validUntilCtrl.text = '31 Dec 2027';
          _bodyTextCtrl.text =
              'By resolution of the Central Governing Board of Shaheed Foundation of India, you are hereby appointed as State Executive Secretary for ${_stateCtrl.text}.\n\nYou are entrusted to lead state-level mission execution, veteran support operations, and volunteer mobilization with highest integrity and dedication.';
        } else if (presetKey == 'patron') {
          _designationCtrl.text = 'Honorary National Patron';
          _categoryCtrl.text = 'Patrons Council';
          _letterSubjectCtrl.text = 'Subject: Induction into Honorary National Patrons Council';
          _validUntilCtrl.text = 'Lifetime';
          _bodyTextCtrl.text =
              'Shaheed Foundation of India takes immense pride in welcoming you into the Honorary National Patrons Council.\n\nYour distinguished leadership, patriotic devotion, and steadfast philanthropy serve as an inspiring pillar in empowering the dependents of India\'s brave martyrs.';
        } else {
          _designationCtrl.text = 'Life Welfare Member';
          _categoryCtrl.text = 'Life Welfare Member';
          _letterSubjectCtrl.text = 'Subject: Official Letter of Membership & Association';
          _validUntilCtrl.text = 'Lifetime';
          _bodyTextCtrl.text =
              'Dear $name,\n\nOn behalf of the National Executive Council of Shaheed Foundation of India, we are pleased to confirm your enrollment as a Registered Member in the category of "${_categoryCtrl.text}".\n\nYour commitment to supporting the welfare of the families of our national martyrs and bravehearts is deeply valued. In this capacity, you are authorized to represent our collective mission and participate in national initiatives, memorial ceremonies, and family outreach programs.';
        }
      } else if (widget.type == DocumentType.certificate) {
        if (presetKey == 'honor') {
          _certTitleCtrl.text = 'CERTIFICATE OF HONOR';
          _subTitleCtrl.text = 'Conferred with utmost distinction upon';
          _bodyTextCtrl.text =
              'Presented in solemn honor of extraordinary dedication, supreme benevolence, and exemplary humanitarian service rendered toward the welfare and dignity of our fallen national heroes\' families.';
        } else if (presetKey == 'merit') {
          _certTitleCtrl.text = 'NATIONAL CITATION OF MERIT';
          _subTitleCtrl.text = 'Proudly bestowed in high recognition of';
          _bodyTextCtrl.text =
              'For outstanding volunteer leadership, grassroots mobilization, and tireless dedication in executing martyr children education initiatives during the year 2026.';
        } else if (presetKey == 'philanthropy') {
          _certTitleCtrl.text = 'LIFETIME PHILANTHROPY AWARD';
          _subTitleCtrl.text = 'Awarded with profound gratitude to';
          _bodyTextCtrl.text =
              'In lasting tribute to your generous financial patronage and enduring allegiance to the mission of ensuring no martyr family is left uncared for.';
        } else {
          _certTitleCtrl.text = 'CERTIFICATE OF APPRECIATION';
          _subTitleCtrl.text = 'This certificate is proudly awarded to';
          _bodyTextCtrl.text =
              'In sincere recognition and deep gratitude for your noble commitment, selfless contribution, and steadfast support extended to the families of India\'s brave martyrs.';
        }
      } else if (widget.type == DocumentType.idCard) {
        if (presetKey == 'district') {
          _designationCtrl.text = 'District Welfare Coordinator';
          _validUntilCtrl.text = '31 Dec 2028';
        } else if (presetKey == 'youth') {
          _designationCtrl.text = 'Youth Wing Volunteer';
          _validUntilCtrl.text = '31 Dec 2026';
        } else {
          _designationCtrl.text = 'Life Welfare Member';
          _validUntilCtrl.text = 'Lifetime';
        }
      } else if (widget.type == DocumentType.taxReceipt80G) {
        if (presetKey == '1000') {
          _amountCtrl.text = '1000.00';
        } else if (presetKey == '3500') {
          _amountCtrl.text = '3500.00';
        } else if (presetKey == '5000') {
          _amountCtrl.text = '5000.00';
        } else if (presetKey == '10000') {
          _amountCtrl.text = '10000.00';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: _isEditing ? 620 : 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top App Bar inside modal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.secondaryNavy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit_document : Icons.description,
                    color: AppTheme.primaryGoldLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit: $_title' : _title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Header Mode Switcher / Action Button
                  if (!_isEditing && widget.isEditable) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGoldLight,
                        side: const BorderSide(color: AppTheme.primaryGoldLight),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Edit Fields', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                        if (widget.onEdit != null) {
                          widget.onEdit!();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                  ] else if (_isEditing) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.secondaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        widget.onSave?.call(_getDataMap());
                      },
                    ),
                    const SizedBox(width: 10),
                  ],

                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Document Content / Editor View
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _isEditing ? _buildEditForm() : _buildDocumentBody(context),
              ),
            ),

            // Modal Actions Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: const Border(top: BorderSide(color: AppTheme.cardBorder)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isEditing) ...[
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back, size: 15),
                      label: const Text('Back to Preview'),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Apply Changes & View Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        widget.onSave?.call(_getDataMap());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document updated with your custom edits!'),
                            backgroundColor: Color(0xFF10B981),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    if (widget.isEditable)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryNavy,
                          side: const BorderSide(color: AppTheme.secondaryNavy),
                        ),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('Edit Fields', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                          if (widget.onEdit != null) {
                            widget.onEdit!();
                          }
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Document "$_title" ready for sharing.'),
                                backgroundColor: AppTheme.secondaryNavy,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: AppTheme.secondaryNavy,
                          ),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Save PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Saved "$_title" (PDF) to device downloads.'),
                                backgroundColor: AppTheme.wreathGreen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // INLINE DOCUMENT EDITOR FORM
  // ==========================================
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Presets Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt, color: Color(0xFF4F46E5), size: 16),
                  SizedBox(width: 6),
                  Text('Quick Template Presets (Click to load):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _getPresetChips(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section 1: Recipient Information
        const Text('1. Recipient Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDialogField('Legal Name', _nameCtrl, Icons.person)),
            const SizedBox(width: 10),
            Expanded(child: _buildDialogField('Member / Roll ID', _idCtrl, Icons.badge)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDialogField('Designation / Title', _designationCtrl, Icons.work)),
            const SizedBox(width: 10),
            Expanded(child: _buildDialogField('Category', _categoryCtrl, Icons.category)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDialogField('District / City', _districtCtrl, Icons.location_city)),
            const SizedBox(width: 10),
            Expanded(child: _buildDialogField('State', _stateCtrl, Icons.map)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDialogField('Mobile Phone', _phoneCtrl, Icons.phone)),
            const SizedBox(width: 10),
            Expanded(child: _buildDialogField('Email Address', _emailCtrl, Icons.email)),
          ],
        ),
        const SizedBox(height: 16),

        // Section 2: Document Specific Configuration
        Text('2. $_title Configuration', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),

        if (widget.type == DocumentType.idCard) ...[
          Row(
            children: [
              Expanded(child: _buildDialogField('Blood Group', _bloodGroupCtrl, Icons.bloodtype)),
              const SizedBox(width: 10),
              Expanded(child: _buildDialogField('Validity Term', _validUntilCtrl, Icons.event_available)),
            ],
          ),
        ] else if (widget.type == DocumentType.appointmentLetter) ...[
          Row(
            children: [
              Expanded(child: _buildDialogField('Dispatch Ref No.', _refNumberCtrl, Icons.numbers)),
              const SizedBox(width: 10),
              Expanded(child: _buildDialogField('Tenure / Validity', _validUntilCtrl, Icons.event_available)),
            ],
          ),
          const SizedBox(height: 10),
          _buildDialogField('Letter Subject Line', _letterSubjectCtrl, Icons.subject),
          const SizedBox(height: 10),
          const Text('Appointment Letter Body Paragraph:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _bodyTextCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 12, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Enter appointment preamble and authority message...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ] else if (widget.type == DocumentType.certificate) ...[
          Row(
            children: [
              Expanded(child: _buildDialogField('Certificate Award Title', _certTitleCtrl, Icons.military_tech)),
              const SizedBox(width: 10),
              Expanded(child: _buildDialogField('Presentation Line', _subTitleCtrl, Icons.subtitles)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Certificate Citation & Gratitude Text:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _bodyTextCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 12, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Enter citation text recognizing service and dedication...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ] else if (widget.type == DocumentType.taxReceipt80G) ...[
          Row(
            children: [
              Expanded(child: _buildDialogField('Donation Amount (₹)', _amountCtrl, Icons.currency_rupee)),
              const SizedBox(width: 10),
              Expanded(child: _buildDialogField('Receipt Number', _receiptCtrl, Icons.receipt)),
            ],
          ),
          const SizedBox(height: 10),
          _buildDialogField('PAN Number (Donor / Trustee)', _panCtrl, Icons.credit_card),
        ],

        const SizedBox(height: 16),

        // Section 3: Signatory & Issuance Authority
        const Text('3. Authorized Signatory & Issuance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDialogField('Signatory Name', _signatoryNameCtrl, Icons.draw)),
            const SizedBox(width: 10),
            Expanded(child: _buildDialogField('Signatory Title', _signatoryTitleCtrl, Icons.assignment_ind)),
          ],
        ),
        const SizedBox(height: 10),
        _buildDialogField('Issue Date (YYYY-MM-DD)', _issueDateCtrl, Icons.calendar_today),
      ],
    );
  }

  List<Widget> _getPresetChips() {
    if (widget.type == DocumentType.appointmentLetter) {
      return [
        _presetButton('Life Member', () => _applyDialogPreset('default')),
        _presetButton('District Coordinator', () => _applyDialogPreset('district')),
        _presetButton('State Secretary', () => _applyDialogPreset('state')),
        _presetButton('National Patron', () => _applyDialogPreset('patron')),
      ];
    } else if (widget.type == DocumentType.certificate) {
      return [
        _presetButton('Appreciation Citation', () => _applyDialogPreset('default')),
        _presetButton('Certificate of Honor', () => _applyDialogPreset('honor')),
        _presetButton('Citation of Merit', () => _applyDialogPreset('merit')),
        _presetButton('Lifetime Philanthropy', () => _applyDialogPreset('philanthropy')),
      ];
    } else if (widget.type == DocumentType.idCard) {
      return [
        _presetButton('Life Member (Lifetime)', () => _applyDialogPreset('default')),
        _presetButton('District Coordinator (2 Yrs)', () => _applyDialogPreset('district')),
        _presetButton('Youth Wing (1 Yr)', () => _applyDialogPreset('youth')),
      ];
    } else {
      return [
        _presetButton('₹1,000', () => _applyDialogPreset('1000')),
        _presetButton('₹3,500', () => _applyDialogPreset('3500')),
        _presetButton('₹5,000', () => _applyDialogPreset('5000')),
        _presetButton('₹10,000', () => _applyDialogPreset('10000')),
      ];
    }
  }

  Widget _presetButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFA5B4FC)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
            prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DOCUMENT PREVIEW RENDERERS
  // ==========================================
  Widget _buildDocumentBody(BuildContext context) {
    final dateStr = _issueDateCtrl.text.isNotEmpty ? _issueDateCtrl.text : DateTime.now().toString().substring(0, 10);

    switch (widget.type) {
      case DocumentType.idCard:
        return _buildIdCardPreview(context, dateStr);
      case DocumentType.appointmentLetter:
        return _buildAppointmentLetter(context, dateStr);
      case DocumentType.certificate:
        return _buildCertificate(context, dateStr);
      case DocumentType.taxReceipt80G:
        return _build80GReceipt(context, dateStr);
    }
  }

  // 1. Digital ID Card
  Widget _buildIdCardPreview(BuildContext context, String dateStr) {
    final effectiveRole = _designationCtrl.text.trim().isNotEmpty
        ? _designationCtrl.text.trim()
        : (_categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : 'Life Welfare Member');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.secondaryNavy, AppTheme.navyDark]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  AppConstants.logoPath,
                  height: 32,
                  errorBuilder: (_, _, _) => const Icon(Icons.shield, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHAHEED FOUNDATION INDIA',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'NATIONAL EXECUTIVE MEMBERSHIP CARD',
                        style: TextStyle(color: AppTheme.primaryGoldLight, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.wreathGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 102,
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 48, color: AppTheme.secondaryNavy),
                      SizedBox(height: 4),
                      Text('PHOTO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nameCtrl.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('ID: ${_idCtrl.text}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
                      Text('Role: $effectiveRole', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                      if (_bloodGroupCtrl.text.isNotEmpty)
                        Text('Blood Group: ${_bloodGroupCtrl.text}', style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      Text('Phone: ${_phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : "N/A"}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text('State: ${_districtCtrl.text}, ${_stateCtrl.text}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text('Issued: $dateStr', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      if (_validUntilCtrl.text.isNotEmpty)
                        Text('Valid Until: ${_validUntilCtrl.text}', style: const TextStyle(fontSize: 10, color: AppTheme.wreathGreen, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.warmCreamLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('U85300HR2022NPL101988', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                Text(
                  _signatoryTitleCtrl.text.isNotEmpty ? 'Auth: ${_signatoryTitleCtrl.text.split('\n').first}' : 'Sec 8 Non-Profit • 80G Exempt',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Appointment Letter
  Widget _buildAppointmentLetter(BuildContext context, String dateStr) {
    final effectiveRole = _designationCtrl.text.trim().isNotEmpty
        ? _designationCtrl.text.trim()
        : (_categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : 'Life Welfare Member');
    final effectiveRef = _refNumberCtrl.text.isNotEmpty
        ? _refNumberCtrl.text
        : 'Ref: SFI/APPT/${DateTime.now().year}/${_idCtrl.text}';
    final effectiveSubject = _letterSubjectCtrl.text.isNotEmpty
        ? _letterSubjectCtrl.text
        : 'Subject: Official Letter of Membership & Association';
    final effectiveBody = _bodyTextCtrl.text.trim().isNotEmpty
        ? _bodyTextCtrl.text
        : 'Dear ${_nameCtrl.text},\n\nOn behalf of the National Executive Council of Shaheed Foundation of India, we are pleased to confirm your enrollment as a Registered Member in the category of "$effectiveRole".\n\nYour commitment to supporting the welfare of the families of our national martyrs and bravehearts is deeply valued. In this capacity, you are authorized to represent our collective mission and participate in national initiatives, memorial ceremonies, and family outreach programs.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppConstants.logoPath,
                height: 36,
                errorBuilder: (_, _, _) => const Icon(Icons.shield, size: 36, color: AppTheme.secondaryNavy),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryNavy),
                    ),
                    Text(
                      'Reg. No. U85300HR2022NPL101988 • Section 8 (Companies Act, 2013)',
                      style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1.5, color: AppTheme.primaryGold),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Date: $dateStr', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ),
          const SizedBox(height: 8),
          Text(effectiveRef, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'To,\n${_nameCtrl.text}\nMember ID: ${_idCtrl.text}\n${_designationCtrl.text.isNotEmpty ? 'Designation: ${_designationCtrl.text}\n' : ''}${_districtCtrl.text}, ${_stateCtrl.text}',
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          Text(
            effectiveSubject,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
          ),
          const SizedBox(height: 10),
          Text(
            effectiveBody,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
          if (_validUntilCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Tenure / Validity: ${_validUntilCtrl.text}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _signatoryNameCtrl.text.isNotEmpty ? _signatoryNameCtrl.text : 'Authorized Signatory',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  Text(
                    _signatoryTitleCtrl.text.isNotEmpty ? _signatoryTitleCtrl.text : 'National Secretary\nShaheed Foundation of India',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const Icon(Icons.verified, color: AppTheme.primaryGold, size: 36),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Certificate of Appreciation
  Widget _buildCertificate(BuildContext context, String dateStr) {
    final effectiveTitle = _certTitleCtrl.text.isNotEmpty ? _certTitleCtrl.text : 'CERTIFICATE OF APPRECIATION';
    final effectiveSubtitle = _subTitleCtrl.text.isNotEmpty ? _subTitleCtrl.text : 'This certificate is proudly awarded to';
    final effectiveCitation = _bodyTextCtrl.text.trim().isNotEmpty
        ? _bodyTextCtrl.text
        : 'In sincere recognition and deep gratitude for your noble commitment, selfless contribution, and steadfast support extended to the families of India\'s brave martyrs.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold, width: 3),
      ),
      child: Column(
        children: [
          Image.asset(
            AppConstants.logoPath,
            height: 44,
            errorBuilder: (_, _, _) => const Icon(Icons.workspace_premium, size: 44, color: AppTheme.primaryGold),
          ),
          const SizedBox(height: 8),
          const Text(
            'SHAHEED FOUNDATION OF INDIA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: AppTheme.secondaryNavy),
            textAlign: TextAlign.center,
          ),
          const Text(
            'A NATION STANDS WITH ITS MARTYRS',
            style: TextStyle(fontSize: 9, letterSpacing: 0.5, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Text(
            effectiveTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkMaroon, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            effectiveSubtitle,
            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _nameCtrl.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondaryNavy),
            textAlign: TextAlign.center,
          ),
          Container(
            width: 140,
            height: 1.5,
            color: AppTheme.primaryGold,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
          Text(
            'Member ID: ${_idCtrl.text}${_designationCtrl.text.isNotEmpty ? ' • ${_designationCtrl.text}' : ''}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
          ),
          const SizedBox(height: 10),
          Text(
            effectiveCitation,
            style: const TextStyle(fontSize: 11, height: 1.4, color: AppTheme.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: $dateStr', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _signatoryNameCtrl.text.isNotEmpty ? _signatoryNameCtrl.text : 'Patron & President',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _signatoryTitleCtrl.text.isNotEmpty ? _signatoryTitleCtrl.text : 'National Council',
                    style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Section 80G Tax Exemption Receipt
  Widget _build80GReceipt(BuildContext context, String dateStr) {
    final amt = double.tryParse(_amountCtrl.text) ?? 1000.0;
    final effectiveReceipt = _receiptCtrl.text.isNotEmpty ? _receiptCtrl.text : 'RCP-80G-${DateTime.now().year}-${_idCtrl.text}';
    final effectivePan = _panCtrl.text.isNotEmpty ? _panCtrl.text : 'AAECS8948K (Trustee)';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryNavy)),
                  Text('Section 80G Tax Exemption Certificate', style: TextStyle(fontSize: 10, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.wreathGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('80G APPROVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.wreathGreen)),
              ),
            ],
          ),
          const Divider(height: 20),
          _receiptRow('Receipt Number:', effectiveReceipt),
          _receiptRow('Donation Date:', dateStr),
          _receiptRow('Donor Name:', _nameCtrl.text),
          _receiptRow('PAN Number:', effectivePan),
          _receiptRow('80G Order Number:', 'CIT(E)/DELHI/80G/2022-23/A/10492'),
          _receiptRow('Payment Mode:', 'Online Transfer / UPI'),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tax-Exempt Contribution:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(
                '₹${amt.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.wreathGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '* Eligible for 50% deduction under Section 80G of Income Tax Act, 1961.',
            style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
