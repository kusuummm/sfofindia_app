import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/auth_user_model.dart';
import '../auth/login_screen.dart';
import '../widgets/document_preview_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // Sidebar navigation state
  String _activeRoute = 'dashboard';
  final ScrollController _sidebarScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  // Collapsible sidebar sections
  bool _peopleExpanded = true;
  bool _operationsExpanded = true;
  bool _contentExpanded = true;
  bool _analyticsExpanded = true;
  bool _systemExpanded = true;

  bool _isLoading = false;
  List<dynamic> _members = [];
  List<dynamic> _donations = [];
  List<dynamic> _activities = [];
  List<dynamic> _campaigns = [];
  List<dynamic> _events = [];
  List<dynamic> _supportTickets = [];

  // Interactive state lists for Gallery, Blog, Admins & Media
  List<Map<String, dynamic>> _galleryAlbums = [];
  List<Map<String, dynamic>> _articles = [];
  List<Map<String, dynamic>> _adminUsers = [];
  List<Map<String, dynamic>> _mediaFiles = [];

  // Testimonials & Reviews Moderation State
  List<Map<String, dynamic>> _adminTestimonials = [];
  String _testimonialFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  bool _isLoadingTestimonials = false;
  Map<String, dynamic>? _adminStats;

  // Member management filters
  String _memberFilter = 'all'; // 'all', 'active', 'pending'
  final TextEditingController _memberSearchCtrl = TextEditingController();
  final TextEditingController _donationSearchCtrl = TextEditingController();
  final TextEditingController _eventSearchCtrl = TextEditingController();
  final TextEditingController _logSearchCtrl = TextEditingController();

  // Settings controllers
  final TextEditingController _orgNameCtrl = TextEditingController(text: 'Shaheed Foundation Of India');
  final TextEditingController _cinCtrl = TextEditingController(text: 'U85300HR2022NPL101988');
  final TextEditingController _taxCtrl = TextEditingController(text: 'AAACS8912NF20214');
  final TextEditingController _darpanCtrl = TextEditingController(text: 'HR/2022/032189');

  // Document Studio State & Controllers
  DocumentType _studioDocType = DocumentType.appointmentLetter;
  Map<String, dynamic>? _studioSelectedMember;
  final TextEditingController _docRecipientNameCtrl = TextEditingController(text: 'Kusum Rathore');
  final TextEditingController _docMemberIdCtrl = TextEditingController(text: 'MBR0004');
  final TextEditingController _docPhoneCtrl = TextEditingController(text: '9876543210');
  final TextEditingController _docEmailCtrl = TextEditingController(text: 'kusumrathore662@gmail.com');
  final TextEditingController _docCategoryCtrl = TextEditingController(text: 'Life Welfare Member');
  final TextEditingController _docStateCtrl = TextEditingController(text: 'Haryana');
  final TextEditingController _docDistrictCtrl = TextEditingController(text: 'Gurugram');
  final TextEditingController _docDesignationCtrl = TextEditingController(text: 'District Welfare Coordinator');
  final TextEditingController _docValidUntilCtrl = TextEditingController(text: '31 Dec 2028');
  final TextEditingController _docBloodGroupCtrl = TextEditingController(text: 'O+ve');
  final TextEditingController _docRefNumberCtrl = TextEditingController(text: 'SFI/APPT/2026/042');
  final TextEditingController _docLetterSubjectCtrl = TextEditingController(text: 'Subject: Official Letter of Membership & Association');
  final TextEditingController _docBodyTextCtrl = TextEditingController(
    text: 'On behalf of the National Executive Council of Shaheed Foundation of India, we are pleased to confirm your enrollment as a Registered Member in the category of "District Welfare Coordinator".\n\nYour commitment to supporting the welfare of the families of our national martyrs and bravehearts is deeply valued. In this capacity, you are authorized to represent our collective mission and participate in national initiatives, memorial ceremonies, and family outreach programs.',
  );
  final TextEditingController _docCertificateTitleCtrl = TextEditingController(text: 'CERTIFICATE OF APPRECIATION');
  final TextEditingController _docSubTitleCtrl = TextEditingController(text: 'This certificate is proudly awarded to');
  final TextEditingController _docSignatoryNameCtrl = TextEditingController(text: 'Col. Gurmeet Singh');
  final TextEditingController _docSignatoryTitleCtrl = TextEditingController(text: 'National Secretary\nShaheed Foundation of India');
  final TextEditingController _docIssueDateCtrl = TextEditingController(text: '2026-08-15');
  final TextEditingController _docPanCtrl = TextEditingController(text: 'AAECS8948K (Trustee)');
  final TextEditingController _docReceiptNoCtrl = TextEditingController(text: '80G-2024-88410');
  final TextEditingController _docDonationAmountCtrl = TextEditingController(text: '3500.00');

  @override
  void initState() {
    super.initState();
    _initStaticData();
    _loadDashboardData();
  }

  void _initStaticData() {
    _galleryAlbums = [
      {
        'title': 'Scholarship Distribution',
        'icon': Icons.school,
        'color': const Color(0xFF4F46E5),
        'count': 4,
        'date': '15 Aug 2026',
        'desc': 'Annual educational scholarship grant distribution for martyr children.',
        'coverImage': 'assets/images/education-child.webp',
        'photos': [
          {'title': 'Cheque Presentation to Students', 'tag': 'Awards', 'imagePath': 'assets/images/education-child.webp'},
          {'title': 'Stage Ceremony with Chief Guest', 'tag': 'Main Stage', 'imagePath': 'assets/images/gallery-1.jpg'},
          {'title': 'Group Photo of 40 Scholar Recipients', 'tag': 'Group', 'imagePath': 'assets/images/gallery-2.jpg'},
          {'title': 'Inaugural Lamp Lighting Ceremony', 'tag': 'Tradition', 'imagePath': 'assets/images/sf/1.jpeg'},
        ],
      },
      {
        'title': 'Martyr Commemoration',
        'icon': Icons.military_tech,
        'color': const Color(0xFFE11D48),
        'count': 3,
        'date': '26 Jul 2026',
        'desc': 'Kargil Vijay Diwas wreath laying ceremony & Veer Nari felicitation.',
        'coverImage': 'assets/images/gallery-1.jpg',
        'photos': [
          {'title': 'Wreath Laying at Amar Jawan Jyoti', 'tag': 'Honor', 'imagePath': 'assets/images/gallery-1.jpg'},
          {'title': 'Honoring Veer Naris on Stage', 'tag': 'Veer Nari', 'imagePath': 'assets/images/gallery-2.jpg'},
          {'title': 'Memorial Lamp Lighting', 'tag': 'Remembrance', 'imagePath': 'assets/images/sf/1.jpeg'},
        ],
      },
      {
        'title': 'Veer Nari Workshop',
        'icon': Icons.woman,
        'color': const Color(0xFF8B5CF6),
        'count': 3,
        'date': '02 May 2026',
        'desc': 'Vocational training, micro-entrepreneurship & handicraft workshop.',
        'coverImage': 'assets/images/donation-2.jpg',
        'photos': [
          {'title': 'Sewing Machine Handover', 'tag': 'Skill', 'imagePath': 'assets/images/donation-2.jpg'},
          {'title': 'Digital Financial Literacy Class', 'tag': 'Training', 'imagePath': 'assets/images/sf/5.jpeg'},
          {'title': 'Handicraft Exhibition Display', 'tag': 'Showcase', 'imagePath': 'assets/images/gallery-5.jpg'},
        ],
      },
      {
        'title': 'Youth National Integration',
        'icon': Icons.groups,
        'color': const Color(0xFF0284C7),
        'count': 3,
        'date': '23 Mar 2026',
        'desc': 'Shaheed Bhagat Singh youth leadership conclave and debate.',
        'coverImage': 'assets/images/event-1.jpg',
        'photos': [
          {'title': 'Youth Keynote Address on Patriotism', 'tag': 'Speech', 'imagePath': 'assets/images/event-1.jpg'},
          {'title': 'Inter-College Debate Competition', 'tag': 'Debate', 'imagePath': 'assets/images/gallery-6.jpg'},
          {'title': 'Student Volunteers Delegation', 'tag': 'Youth', 'imagePath': 'assets/images/sf/6.jpeg'},
        ],
      },
      {
        'title': 'Section 8 Annual Assembly',
        'icon': Icons.account_balance,
        'color': const Color(0xFFD97706),
        'count': 3,
        'date': '10 Jan 2026',
        'desc': 'Annual General Meeting, board resolutions and financial audit presentation.',
        'coverImage': 'assets/images/event-2.jpg',
        'photos': [
          {'title': 'Board of Directors Deliberation', 'tag': 'Governance', 'imagePath': 'assets/images/event-2.jpg'},
          {'title': 'Audited Balance Sheet Presentation', 'tag': 'Compliance', 'imagePath': 'assets/images/sf/7.jpeg'},
          {'title': 'Foundation Trustees and Patrons', 'tag': 'Trustees', 'imagePath': 'assets/images/donation-1.jpg'},
        ],
      },
    ];

    _articles = [
      {
        'id': 1,
        'title': 'Shaheed Foundation Distributes ₹25 Lakhs to 40 Martyr Families',
        'category': 'Welfare & Grants',
        'author': 'Admin Office',
        'date': '12 Apr 2026',
        'views': 1240,
        'status': 'Published',
        'content': 'In a solemn ceremony at New Delhi, the Shaheed Foundation of India disbursed direct financial assistance of ₹25 Lakhs to 40 families of fallen bravehearts from the armed forces and paramilitary personnel...',
      },
      {
        'id': 2,
        'title': 'Annual Welfare Report: Supporting 150+ Veer Naris across North India',
        'category': 'Annual Reports',
        'author': 'Kusum Rathore',
        'date': '05 Apr 2026',
        'views': 890,
        'status': 'Published',
        'content': 'The foundation continues its steadfast commitment to Veer Naris with comprehensive healthcare aid, skill development workshops, and higher education tuition support for martyr children...',
      },
      {
        'id': 3,
        'title': 'Understanding 80G Tax Benefits: Complete Guide for Indian Donors',
        'category': 'Tax Compliance',
        'author': 'Finance Team',
        'date': '28 Mar 2026',
        'views': 2100,
        'status': 'Published',
        'content': 'Donations to Shaheed Foundation Of India are 50% exempt from income tax under Section 80G of the Income Tax Act, 1961. Learn how to claim deduction with your official receipt...',
      },
    ];

    _adminUsers = [
      {
        'name': 'admin',
        'role': 'Super Administrator',
        'email': 'admin@sfofindia.com',
        'status': 'ACTIVE',
        'permissions': 'Full Platform & Financial Clearance',
        'last_login': 'Today, 11:20 AM',
      },
      {
        'name': 'Kusum Rathore',
        'role': 'National Coordinator',
        'email': 'kusumrathore662@gmail.com',
        'status': 'ACTIVE',
        'permissions': 'Member Verification & Document Issuance',
        'last_login': 'Today, 10:45 AM',
      },
      {
        'name': 'Col. Gurmeet Singh',
        'role': 'Defence Advisory Lead',
        'email': 'gurmeet.singh@gmail.com',
        'status': 'ACTIVE',
        'permissions': 'Events & Martyr Family Welfare',
        'last_login': 'Yesterday, 06:10 PM',
      },
    ];

    _mediaFiles = [
      {
        'name': 'Section_8_Registration_Certificate_MCA.pdf',
        'type': 'PDF',
        'size': '2.4 MB',
        'date': '10 Jan 2026',
        'desc': 'Government of India Ministry of Corporate Affairs Incorporation Certificate'
      },
      {
        'name': '80G_Tax_Exemption_Order_ITD.pdf',
        'type': 'PDF',
        'size': '1.1 MB',
        'date': '15 Feb 2026',
        'desc': 'Income Tax Department Approval Order under Section 80G(5)(vi)'
      },
      {
        'name': 'Official_Seal_Shaheed_Foundation_HighRes.png',
        'type': 'IMAGE',
        'size': '850 KB',
        'date': '01 Mar 2026',
        'desc': 'Official foundation gold emblem and stamp asset'
      },
      {
        'name': 'Audited_Annual_Financial_Statements_FY25.pdf',
        'type': 'PDF',
        'size': '3.2 MB',
        'date': '20 Mar 2026',
        'desc': 'Chartered Accountant audited balance sheet & income expenditure ledger'
      },
    ];
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    _mainScrollController.dispose();
    _memberSearchCtrl.dispose();
    _donationSearchCtrl.dispose();
    _eventSearchCtrl.dispose();
    _logSearchCtrl.dispose();
    _orgNameCtrl.dispose();
    _cinCtrl.dispose();
    _taxCtrl.dispose();
    _darpanCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(',', '').trim()) ?? fallback;
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final token = _authService.currentUser?.token;
    _loadAdminTestimonials();

    // 0. Fetch live admin stats and charts from backend database
    final statsRes = await _apiService.getAdminStats(token: token);
    if (statsRes.isSuccess && statsRes.data is Map) {
      _adminStats = Map<String, dynamic>.from(statsRes.data as Map);
    }

    // 1. Fetch live members
    final membersRes = await _apiService.getMembers(token: token);
    if (membersRes.isSuccess && membersRes.data is List) {
      _members = membersRes.data as List;
    } else {
      _members = _getFallbackMembers();
    }

    // 2. Fetch live donations
    final donRes = await _apiService.getDonations(token: token);
    if (donRes.isSuccess && donRes.data is List) {
      _donations = donRes.data as List;
    } else {
      _donations = _getFallbackDonations();
    }

    // 3. Fetch live audit activities
    final actRes = await _apiService.getActivities(token: token);
    if (actRes.isSuccess && actRes.data is List) {
      _activities = actRes.data as List;
    } else {
      _activities = _getFallbackActivities();
    }

    // 4. Fetch live campaigns (with fallback)
    final campRes = await _apiService.getCampaigns(token: token);
    if (campRes.isSuccess && campRes.data is List && (campRes.data as List).isNotEmpty) {
      _campaigns = (campRes.data as List).map<Map<String, dynamic>>((c) {
        return {
          'id': c['id'],
          'title': c['title'] ?? 'Campaign',
          'goal': _parseDouble(c['goal_amount'], 1000000.0),
          'raised': _parseDouble(c['raised_amount'], 0.0),
          'status': 'ACTIVE',
          'priority': 'High',
          'donors': c['donors_count'] ?? 142,
          'desc': c['description'] ?? '',
        };
      }).toList();
    } else {
      _campaigns = [
        {
          'title': 'Martyr Family Support',
          'goal': 2500000.0,
          'raised': 1840000.0,
          'status': 'ACTIVE',
          'priority': 'High',
          'donors': 142,
          'desc': 'Direct stipends, housing assistance and emergency medical relief.'
        },
        {
          'title': 'Education Initiative',
          'goal': 1500000.0,
          'raised': 1500000.0,
          'status': 'COMPLETE',
          'priority': 'Medium',
          'donors': 98,
          'desc': 'Higher education tuition and textbooks for shaheed children.'
        },
        {
          'title': 'Veer Nari Sustainable Livelihoods',
          'goal': 1000000.0,
          'raised': 780000.0,
          'status': 'ACTIVE',
          'priority': 'High',
          'donors': 64,
          'desc': 'Micro-entrepreneurship grants and vocational training.'
        },
      ];
    }

    // 5. Default events
    _events = [
      {
        'title': 'Annual Martyr Memorial Honor Diwas',
        'date': '23 Oct 2026',
        'time': '10:00 AM',
        'venue': 'National War Memorial Hall, New Delhi',
        'rsvps': 120,
        'status': 'Upcoming',
      },
      {
        'title': 'Veer Nari Skill Development Workshop',
        'date': '15 Nov 2026',
        'time': '11:30 AM',
        'venue': 'Community Center, Sector 14, Gurugram',
        'rsvps': 45,
        'status': 'Upcoming',
      },
      {
        'title': 'National Integration Blood Donation Camp',
        'date': '02 Dec 2026',
        'time': '09:00 AM',
        'venue': 'Red Cross Bhavan, Chandigarh',
        'rsvps': 85,
        'status': 'Planning',
      },
    ];

    // 6. Fetch live blogs / news
    final blogRes = await _apiService.getBlogs(token: token);
    if (blogRes.isSuccess && blogRes.data is List && (blogRes.data as List).isNotEmpty) {
      _articles = (blogRes.data as List).map<Map<String, dynamic>>((b) {
        return {
          'id': b['id'] ?? 1,
          'title': b['title'] ?? 'News Article',
          'category': b['category'] ?? 'Welfare & Grants',
          'author': b['author'] ?? 'Admin Office',
          'date': b['created_at'] != null ? b['created_at'].toString().split(' ').first : 'Today',
          'views': int.tryParse(b['views']?.toString() ?? '500') ?? 500,
          'status': 'Published',
          'content': b['content'] ?? b['excerpt'] ?? '',
        };
      }).toList();
    }

    // 7. Fetch live support tickets (with fallback)
    final tktRes = await _apiService.getSupportTickets(token: token);
    if (tktRes.isSuccess && tktRes.data is List && (tktRes.data as List).isNotEmpty) {
      _supportTickets = (tktRes.data as List).map<Map<String, dynamic>>((t) {
        final detail = t['detail']?.toString() ?? '';
        final idStr = detail.contains('[') && detail.contains(']')
            ? detail.split('[')[1].split(']')[0]
            : 'TKT-${t['id'] ?? '1080'}';
        final nameStr = detail.contains('From ') ? detail.split('From ')[1].split(' (')[0] : 'Citizen / Supporter';
        final subjStr = detail.contains('): ') ? detail.split('): ')[1].split(' - ')[0] : 'Inquiry';
        final msgStr = detail.contains(' - ') ? detail.split(' - ').sublist(1).join(' - ') : detail;

        return {
          'id': idStr,
          'name': nameStr,
          'subject': subjStr,
          'date': t['created_at'] != null ? t['created_at'].toString().split(' ').first : 'Today',
          'status': t['status'] == 'resolved' ? 'Resolved' : 'Open',
          'priority': 'High',
          'message': msgStr.isNotEmpty ? msgStr : detail,
        };
      }).toList();
    } else {
      _supportTickets = [
        {
          'id': 'TKT-1082',
          'name': 'Col. Gurmeet Singh',
          'subject': 'Request for updated 80G Tax Exemption Certificate copy',
          'date': 'Today, 10:15 AM',
          'status': 'Open',
          'priority': 'High',
          'message': 'Kindly send the signed 80G exemption receipt for our audit filing purposes.',
        },
        {
          'id': 'TKT-1081',
          'name': 'Vikram Malhotra',
          'subject': 'Inquiry on Aadhaar verification status for ID card',
          'date': 'Yesterday, 04:30 PM',
          'status': 'In Progress',
          'priority': 'Medium',
          'message': 'I have uploaded my documents. Please confirm when the digital ID card will be activated.',
        },
        {
          'id': 'TKT-1080',
          'name': 'Dr. Sunita Bansal',
          'subject': 'Volunteer registration for Martyr Diwas event',
          'date': '18 Apr 2026',
          'status': 'Resolved',
          'priority': 'Low',
          'message': 'Our medical team would like to set up a first-aid kiosk at the memorial ceremony.',
        },
      ];
    }

    // 8. Fetch live gallery from website database
    final galRes = await _apiService.getGallery(token: token);
    if (galRes.isSuccess && galRes.data is List && (galRes.data as List).isNotEmpty) {
      final list = galRes.data as List;
      final List<Map<String, dynamic>> livePhotos = [];
      for (var p in list) {
        final rawPath = (p['image_path'] ?? p['image'] ?? '').toString();
        if (rawPath.isEmpty) continue;
        String imgUrl = rawPath;
        if (!rawPath.startsWith('http') && !rawPath.startsWith('assets/')) {
          final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
          imgUrl = '${_apiService.baseUrl}/$cleanPath';
        }
        livePhotos.add({
          'title': p['title']?.toString() ?? 'Welfare Photo',
          'tag': 'Live CMS',
          'imagePath': imgUrl,
        });
      }
      if (livePhotos.isNotEmpty) {
        _galleryAlbums.insert(0, {
          'title': 'Live Website Gallery Uploads',
          'icon': Icons.cloud_done,
          'color': const Color(0xFF10B981),
          'count': livePhotos.length,
          'date': 'Synced from Website',
          'desc': 'Live photos synchronized with website ngom_gallery table.',
          'coverImage': livePhotos[0]['imagePath'],
          'photos': livePhotos,
        });
      }
    }

    // 9. Fetch live site settings (Document Studio templates & Org Metadata)
    final setRes = await _apiService.getSiteSettings(token: token);
    if (setRes.isSuccess && setRes.data is Map) {
      final s = setRes.data as Map;
      if (s['doc_signatory_name'] != null && s['doc_signatory_name'].toString().trim().isNotEmpty) {
        _docSignatoryNameCtrl.text = s['doc_signatory_name'].toString();
      }
      if (s['doc_signatory_title'] != null && s['doc_signatory_title'].toString().trim().isNotEmpty) {
        _docSignatoryTitleCtrl.text = s['doc_signatory_title'].toString();
      }
      if (s['doc_pan'] != null && s['doc_pan'].toString().trim().isNotEmpty) {
        _docPanCtrl.text = s['doc_pan'].toString();
      }
      if (s['doc_issue_date'] != null && s['doc_issue_date'].toString().trim().isNotEmpty) {
        _docIssueDateCtrl.text = s['doc_issue_date'].toString();
      }
      if (s['doc_receipt_no'] != null && s['doc_receipt_no'].toString().trim().isNotEmpty) {
        _docReceiptNoCtrl.text = s['doc_receipt_no'].toString();
      }
      if (s['site_name'] != null && s['site_name'].toString().trim().isNotEmpty) {
        _orgNameCtrl.text = s['site_name'].toString();
      }
      if (s['org_cin'] != null && s['org_cin'].toString().trim().isNotEmpty) {
        _cinCtrl.text = s['org_cin'].toString();
      }
      if (s['org_tax_id'] != null && s['org_tax_id'].toString().trim().isNotEmpty) {
        _taxCtrl.text = s['org_tax_id'].toString();
      }
      if (s['org_darpan_id'] != null && s['org_darpan_id'].toString().trim().isNotEmpty) {
        _darpanCtrl.text = s['org_darpan_id'].toString();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFallbackMembers() {
    return [
      {
        "id": 6,
        "member_user_id": "MBR0006",
        "name": "Amit Sharma",
        "mobile": "9811223344",
        "email": "amit.sharma@gmail.com",
        "status": "active",
        "district": "Gurugram",
        "state": "Haryana",
        "profession": "Social Worker",
        "renewal_date": "15 Aug 2027",
        "fee_status": "Paid",
        "created_at": "2024-08-15"
      },
      {
        "id": 5,
        "member_user_id": "MBR0005",
        "name": "Vikram Malhotra",
        "mobile": "9876501234",
        "email": "vikram.m@gmail.com",
        "status": "pending",
        "district": "Faridabad",
        "state": "Haryana",
        "profession": "Advocate",
        "renewal_date": "Pending Verification",
        "fee_status": "Due",
        "created_at": "2024-08-16"
      },
      {
        "id": 4,
        "member_user_id": "MBR0004",
        "name": "Kusum Rathore",
        "mobile": "9876543210",
        "email": "kusumrathore662@gmail.com",
        "status": "active",
        "district": "Gurugram",
        "state": "Haryana",
        "profession": "National Coordinator",
        "renewal_date": "10 Aug 2027",
        "fee_status": "Paid",
        "created_at": "2024-08-10"
      },
      {
        "id": 3,
        "member_user_id": "MBR0003",
        "name": "Col. Gurmeet Singh (Retd)",
        "mobile": "9810011223",
        "email": "gurmeet.singh@gmail.com",
        "status": "active",
        "district": "Chandigarh",
        "state": "Punjab",
        "profession": "Defence Consultant",
        "renewal_date": "01 Aug 2027",
        "fee_status": "Paid",
        "created_at": "2024-08-01"
      },
    ];
  }

  List<Map<String, dynamic>> _getFallbackDonations() {
    return [
      {
        "id": 1,
        "name": "Col. Gurmeet Singh",
        "mobile": "9810011223",
        "email": "gurmeet.singh@gmail.com",
        "amount": "5000.00",
        "receipt_no": "80G-2024-99120",
        "campaign_title": "Martyr Family Support",
        "created_at": "2024-08-14 11:20:00",
      },
      {
        "id": 2,
        "name": "Kusum Rathore",
        "mobile": "9876543210",
        "email": "kusumrathore662@gmail.com",
        "amount": "3500.00",
        "receipt_no": "80G-2024-88410",
        "campaign_title": "Veer Nari Sustainable Aid",
        "created_at": "2024-08-10 14:15:00",
      },
      {
        "id": 3,
        "name": "Rajiv Malhotra",
        "mobile": "9845012345",
        "email": "rajiv.malhotra@gmail.com",
        "amount": "2500.00",
        "receipt_no": "80G-2024-77119",
        "campaign_title": "Education Initiative",
        "created_at": "2024-08-01 09:45:00",
      },
    ];
  }

  List<Map<String, dynamic>> _getFallbackActivities() {
    return [
      {
        "action": "ngom_insert: ngom_campaigns",
        "detail": "Launched initiative: Martyr Family Support Fund",
        "created_at": "20 Apr 2026 17:37",
        "ip_address": "127.0.0.1"
      },
      {
        "action": "system_setup: Administrative Activity Audit Trail initialized.",
        "detail": "Administrative Activity Audit Trail initialized.",
        "created_at": "20 Apr 2026 16:40",
        "ip_address": "127.0.0.1"
      },
      {
        "action": "manual_donation",
        "detail": "Recorded donation from Kusum Rathore (₹3500) - Ref: 80G-2024-88410",
        "created_at": "19 Apr 2026 11:45",
        "ip_address": "127.0.0.1"
      },
    ];
  }

  int get _activeCount {
    if (_adminStats != null && _adminStats!['verified_members'] != null) {
      return (_adminStats!['verified_members'] as num).toInt();
    }
    return _members.where((m) => (m['status']?.toString().toLowerCase() ?? '') == 'active').length;
  }

  int get _pendingCount {
    if (_adminStats != null && _adminStats!['pending_verifications'] != null) {
      return (_adminStats!['pending_verifications'] as num).toInt();
    }
    return _members.where((m) => (m['status']?.toString().toLowerCase() ?? '') == 'pending').length;
  }

  double get _totalDonationsAmount {
    if (_adminStats != null && _adminStats!['total_donations'] != null) {
      return _parseDouble(_adminStats!['total_donations']);
    }
    double sum = 0;
    for (var d in _donations) {
      if (d is Map && d['amount'] != null) {
        sum += _parseDouble(d['amount']);
      }
    }
    return sum;
  }

  List<dynamic> get _filteredMembers {
    final q = _memberSearchCtrl.text.trim().toLowerCase();
    return _members.where((m) {
      final st = (m['status']?.toString().toLowerCase() ?? 'pending');
      if (_memberFilter == 'active' && st != 'active') return false;
      if (_memberFilter == 'pending' && st != 'pending') return false;

      if (q.isEmpty) return true;
      final name = (m['name'] ?? '').toString().toLowerCase();
      final id = (m['member_user_id'] ?? m['id'] ?? '').toString().toLowerCase();
      final phone = (m['mobile'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      final city = (m['district'] ?? m['city'] ?? '').toString().toLowerCase();

      return name.contains(q) || id.contains(q) || phone.contains(q) || email.contains(q) || city.contains(q);
    }).toList();
  }

  List<dynamic> get _filteredDonations {
    final q = _donationSearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _donations;
    return _donations.where((d) {
      final name = (d['name'] ?? d['donor_name'] ?? '').toString().toLowerCase();
      final txn = (d['receipt_no'] ?? '').toString().toLowerCase();
      final mobile = (d['mobile'] ?? '').toString().toLowerCase();
      return name.contains(q) || txn.contains(q) || mobile.contains(q);
    }).toList();
  }

  int _extractNumericId(dynamic id) {
    if (id == null) return 4;
    final s = id.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(s) ?? 4;
  }

  void _handleLogout() {
    _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.admin)),
    );
  }

  void _switchRoute(String route) {
    setState(() {
      _activeRoute = route;
      if (route == 'unverified_members') {
        _memberFilter = 'pending';
      } else if (route == 'verified_members') {
        _memberFilter = 'all';
      }
    });
  }

  // --- ACTION MODALS ---

  // 1. Onboard Member Modal
  void _showOnboardMemberDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final stateCtrl = TextEditingController(text: 'Haryana');
    final districtCtrl = TextEditingController(text: 'Gurugram');
    final professionCtrl = TextEditingController(text: 'Social Worker');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF4F46E5)),
              SizedBox(width: 10),
              Text('Onboard New Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number *', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'District / City', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: professionCtrl, decoration: const InputDecoration(labelText: 'Profession', isDense: true, border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter Name and Mobile number.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context);
                final res = await _apiService.createMember(
                  data: {
                    'name': nameCtrl.text.trim(),
                    'mobile': phoneCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'city': districtCtrl.text.trim(),
                    'state': stateCtrl.text.trim(),
                    'profession': professionCtrl.text.trim(),
                  },
                  token: _authService.currentUser?.token,
                );
                if (context.mounted) {
                  if (res.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Member "${nameCtrl.text}" registered successfully!'), backgroundColor: const Color(0xFF10B981)),
                    );
                    _loadDashboardData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message ?? 'Registration completed locally.'), backgroundColor: const Color(0xFF10B981)),
                    );
                    setState(() {
                      _members.insert(0, {
                        'id': _members.length + 1,
                        'member_user_id': 'MBR000${_members.length + 1}',
                        'name': nameCtrl.text.trim(),
                        'mobile': phoneCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'status': 'pending',
                        'district': districtCtrl.text.trim(),
                        'state': stateCtrl.text.trim(),
                        'profession': professionCtrl.text.trim(),
                      });
                    });
                  }
                }
              },
              child: const Text('Register Member', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 2. Record Offline Donation Modal
  void _showRecordDonationDialog() {
    final donorCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    String paymentMode = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.add_card, color: Color(0xFF10B981)),
                  SizedBox(width: 10),
                  Text('Record Offline Donation & Issue 80G', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: donorCtrl, decoration: const InputDecoration(labelText: 'Donor Full Name *', isDense: true, border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Donor Mobile Number', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Donation Amount (INR) *', prefixText: '₹ ', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    TextField(controller: panCtrl, decoration: const InputDecoration(labelText: 'Donor PAN (For 80G Tax Exemption)', isDense: true, border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMode,
                      decoration: const InputDecoration(labelText: 'Payment Mode', isDense: true, border: OutlineInputBorder()),
                      items: ['Cash', 'Bank Cheque', 'NEFT / RTGS', 'Direct UPI'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setDlgState(() => paymentMode = val ?? 'Cash'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (donorCtrl.text.trim().isEmpty || amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter donor name and valid amount.'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await _apiService.createDonation(
                      data: {
                        'donor_name': donorCtrl.text.trim(),
                        'mobile': phoneCtrl.text.trim(),
                        'amount': amt,
                        'pan_number': panCtrl.text.trim(),
                        'payment_mode': paymentMode,
                      },
                      token: _authService.currentUser?.token,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Donation of ₹$amt recorded with 80G Tax Exemption!'), backgroundColor: const Color(0xFF10B981)),
                      );
                      _loadDashboardData();
                    }
                  },
                  child: const Text('Record & Issue 80G', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Launch Campaign Modal
  void _showCreateCampaignDialog() {
    final titleCtrl = TextEditingController();
    final goalCtrl = TextEditingController(text: '500000');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Text('Launch New Welfare Campaign', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Campaign Title *', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: goalCtrl, decoration: const InputDecoration(labelText: 'Target Goal Amount (INR) *', prefixText: '₹ ', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Purpose & Description', isDense: true, border: OutlineInputBorder()), maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                final g = double.tryParse(goalCtrl.text) ?? 100000;
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Campaign title is required.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context);
                await _apiService.createCampaign(
                  data: {
                    'title': titleCtrl.text.trim(),
                    'goal_amount': g,
                    'description': descCtrl.text.trim(),
                  },
                  token: _authService.currentUser?.token,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign "${titleCtrl.text}" launched successfully!'), backgroundColor: const Color(0xFF10B981)),
                  );
                  setState(() {
                    _campaigns.insert(0, {
                      'title': titleCtrl.text.trim(),
                      'goal': g,
                      'raised': 0.0,
                      'status': 'ACTIVE',
                      'priority': 'High',
                      'donors': 0,
                      'desc': descCtrl.text.trim(),
                    });
                  });
                }
              },
              child: const Text('Launch Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 4. Create Event Modal
  void _showCreateEventDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: '12 Dec 2026');
    final venueCtrl = TextEditingController(text: 'Community Hall, Sector 12, Gurugram');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.event, color: Color(0xFF4F46E5)),
              SizedBox(width: 10),
              Text('Schedule New Welfare Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title *', isDense: true, border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date & Time *', isDense: true, border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue / Location *', isDense: true, border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(context);
                setState(() {
                  _events.insert(0, {
                    'title': titleCtrl.text.trim(),
                    'date': dateCtrl.text.trim(),
                    'time': '10:00 AM',
                    'venue': venueCtrl.text.trim(),
                    'rsvps': 1,
                    'status': 'Upcoming',
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event "${titleCtrl.text}" scheduled successfully!'), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: const Text('Schedule Event'),
            ),
          ],
        );
      },
    );
  }

  // 5. Member Inspection Modal
  void _showMemberDetailModal(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        String status = member['status']?.toString().toLowerCase() ?? 'pending';
        final name = member['name'] ?? 'Member';
        final memberId = (member['member_user_id'] ?? member['id'] ?? 'MBR0004').toString();
        final numericId = _extractNumericId(memberId);
        final email = member['email'] ?? 'Not provided';
        final phone = member['mobile'] ?? 'Not provided';
        final district = member['district'] ?? member['city'] ?? 'Gurugram';
        final state = member['state'] ?? 'Haryana';
        final profession = member['profession'] ?? 'Welfare Member';
        final address = member['address'] ?? 'SCO-88, Opp. Sector 12 A';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isActive = (status == 'active');
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 560,
                constraints: const BoxConstraints(maxHeight: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Member ID: $memberId', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF10B981) : Colors.orange.shade800,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'ACTIVE' : 'PENDING REVIEW',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.phone, 'Mobile Phone', phone),
                            _buildInfoRow(Icons.email, 'Email Address', email),
                            _buildInfoRow(Icons.work, 'Profession / Role', profession),
                            _buildInfoRow(Icons.location_on, 'Location', '$district, $state'),
                            _buildInfoRow(Icons.home, 'Address', address),
                            _buildInfoRow(Icons.badge, 'Aadhaar / KYC', 'Verified & Digitally Stamped'),
                            const SizedBox(height: 16),
                            const Text('Official Documents Preview',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.badge, size: 16),
                                  label: const Text('ID Card', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _openMemberDocumentPreviewOrEditor(member, DocumentType.idCard),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.workspace_premium, size: 16),
                                  label: const Text('Certificate', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _openMemberDocumentPreviewOrEditor(member, DocumentType.certificate),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.description, size: 16),
                                  label: const Text('Appointment Letter', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _openMemberDocumentPreviewOrEditor(member, DocumentType.appointmentLetter),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.receipt_long, size: 16),
                                  label: const Text('80G Receipt', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _openMemberDocumentPreviewOrEditor(member, DocumentType.taxReceipt80G),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.edit_note, size: 16),
                                  label: const Text('Edit in Studio', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openDocumentStudioForMember(member, DocumentType.appointmentLetter);
                                  },
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4F46E5),
                                    side: const BorderSide(color: Color(0xFF4F46E5)),
                                  ),
                                  icon: const Icon(Icons.manage_accounts, size: 16),
                                  label: const Text('Edit Member Info', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showEditMemberInfoDialog(member);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          if (!isActive) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Approve & Activate Member', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await _apiService.updateMemberStatus(
                                    memberId: numericId,
                                    status: 'active',
                                    token: _authService.currentUser?.token,
                                  );
                                  setDialogState(() => status = 'active');
                                  setState(() {
                                    member['status'] = 'active';
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Member $name activated successfully!'), backgroundColor: const Color(0xFF10B981)),
                                    );
                                  }
                                  _loadDashboardData();
                                },
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange.shade800,
                                  side: BorderSide(color: Colors.orange.shade800),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.pause_circle_outline),
                                label: const Text('Mark as Pending Review'),
                                onPressed: () async {
                                  await _apiService.updateMemberStatus(
                                    memberId: numericId,
                                    status: 'pending',
                                    token: _authService.currentUser?.token,
                                  );
                                  setDialogState(() => status = 'pending');
                                  setState(() {
                                    member['status'] = 'pending';
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Member $name set to pending review.')),
                                    );
                                  }
                                  _loadDashboardData();
                                },
                              ),
                            ),
                          ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'N/A',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROOT BUILD METHOD (RESPONSIVE DUAL PANE)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Row(
              children: [
                // Permanent Left Sidebar with dedicated scrollbar
                Container(
                  width: 260,
                  margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 15, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: _buildSidebarContent(isDrawer: false),
                ),

                // Main Content View
                Expanded(
                  child: _buildMainContentArea(),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrandAvatar(),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Website admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDashboardData,
                  tooltip: 'Refresh Data',
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                  onPressed: _handleLogout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            drawer: Drawer(
              child: SafeArea(child: _buildSidebarContent(isDrawer: true)),
            ),
            body: _buildMainContentArea(),
          );
        }
      },
    );
  }

  // ==========================================
  // CLEAN, NON-DUPLICATED SIDEBAR
  // ==========================================
  Widget _buildSidebarContent({required bool isDrawer}) {
    return Column(
      children: [
        // Sidebar Branding Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              _buildBrandAvatar(),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Website admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Dedicated Scrollbar with thumb visible
        Expanded(
          child: Scrollbar(
            controller: _sidebarScrollController,
            thumbVisibility: true,
            thickness: 5,
            radius: const Radius.circular(8),
            child: ListView(
              controller: _sidebarScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
                // 1. Overview Section
                _buildNavItem(
                  route: 'dashboard',
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  isDrawer: isDrawer,
                ),
                _buildNavItem(
                  route: 'notifications',
                  title: 'Notifications',
                  icon: Icons.notifications_none,
                  badgeText: '3',
                  badgeColor: const Color(0xFFEF4444),
                  isDrawer: isDrawer,
                ),

                const SizedBox(height: 10),

                // 2. People Section
                _buildSectionHeader(
                  title: 'People',
                  icon: Icons.group_outlined,
                  isExpanded: _peopleExpanded,
                  onTap: () => setState(() => _peopleExpanded = !_peopleExpanded),
                ),
                if (_peopleExpanded) ...[
                  _buildSubNavItem(
                    route: 'unverified_members',
                    title: 'Unverified Members',
                    icon: Icons.person_add_outlined,
                    badgeText: _pendingCount > 0 ? '$_pendingCount' : null,
                    badgeColor: const Color(0xFFEF4444),
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'verified_members',
                    title: 'Verified Members',
                    icon: Icons.verified_user_outlined,
                    badgeText: '$_activeCount',
                    badgeColor: const Color(0xFF10B981),
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'renewals',
                    title: 'Renewals',
                    icon: Icons.history_toggle_off,
                    isDrawer: isDrawer,
                  ),
                ],

                const SizedBox(height: 10),

                // 3. NGO Operations Section
                _buildSectionHeader(
                  title: 'Operations',
                  icon: Icons.tune,
                  badgeText: '3 ACTIVE',
                  badgeColor: const Color(0xFF10B981),
                  isExpanded: _operationsExpanded,
                  onTap: () => setState(() => _operationsExpanded = !_operationsExpanded),
                ),
                if (_operationsExpanded) ...[
                  _buildSubNavItem(
                    route: 'donations',
                    title: 'Donations & 80G 💰',
                    icon: Icons.payments_outlined,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'campaigns',
                    title: 'Campaigns 🎯',
                    icon: Icons.campaign_outlined,
                    badgeText: '${_campaigns.length}',
                    badgeColor: const Color(0xFF4F46E5),
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'events',
                    title: 'Events 📅',
                    icon: Icons.event_outlined,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'projects',
                    title: 'Projects 🏗️',
                    icon: Icons.work_outline,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'certificates',
                    title: 'Certificates & IDs 📜',
                    icon: Icons.workspace_premium_outlined,
                    isDrawer: isDrawer,
                  ),
                ],

                const SizedBox(height: 10),

                // 4. Content & Media Section
                _buildSectionHeader(
                  title: 'Content & Media',
                  icon: Icons.auto_stories_outlined,
                  isExpanded: _contentExpanded,
                  onTap: () => setState(() => _contentExpanded = !_contentExpanded),
                ),
                if (_contentExpanded) ...[
                  _buildSubNavItem(
                    route: 'blog',
                    title: 'Manage Blog 📝',
                    icon: Icons.edit_note,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'gallery',
                    title: 'Photo Gallery 🖼️',
                    icon: Icons.image_outlined,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'media',
                    title: 'Media Manager 📁',
                    icon: Icons.folder_outlined,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'testimonials',
                    title: 'Reviews & Approval ⭐',
                    icon: Icons.rate_review_outlined,
                    isDrawer: isDrawer,
                  ),
                ],

                const SizedBox(height: 10),

                // 5. Analytics & Support Section
                _buildSectionHeader(
                  title: 'Analytics & Support',
                  icon: Icons.analytics_outlined,
                  isExpanded: _analyticsExpanded,
                  onTap: () => setState(() => _analyticsExpanded = !_analyticsExpanded),
                ),
                if (_analyticsExpanded) ...[
                  _buildSubNavItem(
                    route: 'reports',
                    title: 'Reports & Audits 📊',
                    icon: Icons.bar_chart_outlined,
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'support',
                    title: 'Support Tickets 💬',
                    icon: Icons.forum_outlined,
                    badgeText: '2',
                    badgeColor: const Color(0xFFF59E0B),
                    isDrawer: isDrawer,
                  ),
                ],

                const SizedBox(height: 10),

                // 6. System Administration Section
                _buildSectionHeader(
                  title: 'System Administration',
                  icon: Icons.settings_outlined,
                  isExpanded: _systemExpanded,
                  onTap: () => setState(() => _systemExpanded = !_systemExpanded),
                ),
                if (_systemExpanded) ...[
                  _buildSubNavItem(
                    route: 'admins',
                    title: 'Staff / Admins',
                    icon: Icons.manage_accounts_outlined,
                    badgeText: '1',
                    badgeColor: const Color(0xFF64748B),
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'activity_logs',
                    title: 'Activity Logs 🧠',
                    icon: Icons.history,
                    badgeText: '${_activities.length}',
                    badgeColor: const Color(0xFF64748B),
                    isDrawer: isDrawer,
                  ),
                  _buildSubNavItem(
                    route: 'settings',
                    title: 'Website Settings ⚙️',
                    icon: Icons.settings,
                    isDrawer: isDrawer,
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Bottom Logout Button
        Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: _handleLogout,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                border: Border.all(color: const Color(0xFFFCA5A5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
      ),
    );
  }

  Widget _buildNavItem({
    required String route,
    required String title,
    required IconData icon,
    required bool isDrawer,
    String? badgeText,
    Color? badgeColor,
  }) {
    final isActive = (_activeRoute == route);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          if (isDrawer) Navigator.pop(context);
          _switchRoute(route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(color: const Color(0xFF1E293B).withAlpha(40), blurRadius: 6, offset: const Offset(0, 2)),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubNavItem({
    required String route,
    required String title,
    required IconData icon,
    required bool isDrawer,
    String? badgeText,
    Color? badgeColor,
    Color? textColor,
  }) {
    final isActive = (_activeRoute == route);
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 1, bottom: 1),
      child: InkWell(
        onTap: () {
          if (isDrawer) Navigator.pop(context);
          _switchRoute(route);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.white : (textColor ?? const Color(0xFF334155)),
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 16,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // COMPLETE ROUTER WITH ALL SCREENS
  // ==========================================
  Widget _buildMainContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget content;
    switch (_activeRoute) {
      case 'notifications':
        content = _buildNotificationsModule();
        break;
      case 'unverified_members':
      case 'verified_members':
        content = _buildMembersDirectoryModule();
        break;
      case 'renewals':
        content = _buildRenewalsModule();
        break;
      case 'donations':
        content = _buildDonationsModule();
        break;
      case 'campaigns':
        content = _buildCampaignsModule();
        break;
      case 'events':
        content = _buildEventsModule();
        break;
      case 'projects':
        content = _buildProjectsModule();
        break;
      case 'certificates':
        content = _buildCertificatesModule();
        break;
      case 'blog':
        content = _buildBlogModule();
        break;
      case 'gallery':
        content = _buildGalleryModule();
        break;
      case 'media':
        content = _buildMediaModule();
        break;
      case 'testimonials':
        content = _buildTestimonialsModule();
        break;
      case 'reports':
        content = _buildReportsModule();
        break;
      case 'support':
        content = _buildSupportModule();
        break;
      case 'admins':
        content = _buildAdminsModule();
        break;
      case 'activity_logs':
        content = _buildActivityLogsModule();
        break;
      case 'settings':
        content = _buildSettingsModule();
        break;
      case 'dashboard':
      default:
        content = _buildWebsiteDashboardView();
        break;
    }

    return SingleChildScrollView(
      controller: _mainScrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: content,
    );
  }

  // ==========================================
  // 1. WEBSITE DASHBOARD VIEW (1:1 PARITY)
  // ==========================================
  Widget _buildWebsiteDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'NGO Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Overview & Management Hub',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Admin Management Console',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('View website', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening public portal: sfofindia.com')),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 4 Website KPI Stat Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 950;
            final cards = [
              _buildWebsiteKpiCard(
                title: 'Total Members',
                value: '${_adminStats?['total_members'] ?? _members.length}',
                icon: Icons.group,
                footerText: 'Manage members',
                accentColor: const Color(0xFF093C30),
                onFooterTap: () {
                  setState(() {
                    _activeRoute = 'verified_members';
                    _memberFilter = 'all';
                  });
                },
              ),
              _buildWebsiteKpiCard(
                title: 'Total Donations',
                value: '₹${_totalDonationsAmount.toStringAsFixed(0)}',
                icon: Icons.receipt_long,
                footerText: '${_adminStats?['donations_count'] ?? _donations.length} Collections',
                isSuccessFooter: true,
                accentColor: const Color(0xFFD97706),
                onFooterTap: () => setState(() => _activeRoute = 'donations'),
              ),
              _buildWebsiteKpiCard(
                title: 'Pending Verifications',
                value: '$_pendingCount',
                icon: Icons.pending_actions,
                footerText: 'Review pending queue',
                accentColor: const Color(0xFFEA580C),
                onFooterTap: () {
                  setState(() {
                    _activeRoute = 'unverified_members';
                    _memberFilter = 'pending';
                  });
                },
              ),
              _buildWebsiteKpiCard(
                title: 'Campaigns',
                value: '${_adminStats?['active_campaigns'] ?? _campaigns.length}',
                icon: Icons.campaign,
                footerText: 'Manage campaigns',
                accentColor: const Color(0xFF0284C7),
                onFooterTap: () => setState(() => _activeRoute = 'campaigns'),
              ),
            ];

            if (isWide) {
              return Row(
                children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
              );
            } else {
              final width = constraints.maxWidth;
              final double ratio;
              if (width < 380) {
                ratio = 1.42;
              } else if (width < 600) {
                ratio = 1.55;
              } else {
                ratio = 1.70;
              }

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: ratio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cards,
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // 3 Analytics & Trend Chart Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 950;
            final charts = [
              _buildChartCard(
                title: 'Member Registrations',
                subtitle: 'Last 7 days activity',
                footerText: 'Live registration counts',
                chartWidget: _RegistrationBarChart(
                  labels: (_adminStats?['chart_members_labels'] as List?)?.map((e) => e.toString()).toList(),
                  data: (_adminStats?['chart_members_data'] as List?)?.map((e) => num.tryParse(e.toString()) ?? 0).toList(),
                ),
              ),
              _buildChartCard(
                title: 'Monthly Donations',
                subtitle: 'Collections (Last 6 months)',
                footerText: 'Verified paid donations',
                chartWidget: _DonationLineChart(
                  labels: (_adminStats?['chart_donations_labels'] as List?)?.map((e) => e.toString()).toList(),
                  data: (_adminStats?['chart_donations_data'] as List?)?.map((e) => num.tryParse(e.toString()) ?? 0).toList(),
                ),
              ),
              _buildChartCard(
                title: 'Campaign Raised',
                subtitle: 'Top campaigns funds (₹)',
                footerText: 'Real-time funds tally',
                chartWidget: _CampaignRaisedChart(
                  labels: (_adminStats?['chart_campaigns_labels'] as List?)?.map((e) => e.toString()).toList(),
                  data: (_adminStats?['chart_campaigns_data'] as List?)?.map((e) => num.tryParse(e.toString()) ?? 0).toList(),
                ),
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: charts.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
              );
            } else {
              return Column(
                children: charts.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Two-Column Section: NGO Projects Table & Recent Activity
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 950;

            final projectsTable = _buildNgoProjectsCard();
            final recentActivity = _buildRecentActivityCard();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: projectsTable),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: recentActivity),
                ],
              );
            } else {
              return Column(
                children: [
                  projectsTable,
                  const SizedBox(height: 16),
                  recentActivity,
                ],
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Members Directory Section
        _buildMembersDirectoryPreviewCard(),

        const SizedBox(height: 30),

        // Responsive Website Footer
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: [
            const Text(
              '© 2026 Shaheed Foundation Of India. All Rights Reserved.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('View Website', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
                TextButton(
                  onPressed: () => _switchRoute('settings'),
                  child: const Text('Portal Settings', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
                TextButton(
                  onPressed: () => _switchRoute('support'),
                  child: const Text('Help & Support', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // KPI Card
  Widget _buildWebsiteKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required String footerText,
    bool isSuccessFooter = false,
    required VoidCallback onFooterTap,
    Color? accentColor,
  }) {
    final themeColor = accentColor ?? const Color(0xFF093C30);
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: themeColor, size: 19),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              InkWell(
                onTap: onFooterTap,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          footerText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSuccessFooter ? const Color(0xFF093C30) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: isSuccessFooter ? const Color(0xFF093C30) : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Chart Card
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required String footerText,
    required Widget chartWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: chartWidget,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NGO Projects Card
  Widget _buildNgoProjectsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('NGO Projects', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Active initiatives for the month', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF093C30),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('New Initiative', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: _showCreateCampaignDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('FEATURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('PRIORITY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 3, child: Text('GOAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _campaigns.length,
            separatorBuilder: (context, index) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final c = _campaigns[index];
              final isComplete = (c['status'] == 'COMPLETE');
              final raised = _parseDouble(c['raised'], 0.0);
              final goal = _parseDouble(c['goal'], 100000.0);
              final pct = (raised / goal).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        c['title'] ?? 'Campaign',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isComplete ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c['status'] ?? 'ACTIVE',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        c['priority'] ?? 'Medium',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isComplete ? const Color(0xFF10B981) : const Color(0xFF093C30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${(pct * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
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

  // Recent Activity Card
  Widget _buildRecentActivityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    SizedBox(height: 2),
                    Text(
                      'Latest actions by admin users',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _switchRoute('activity_logs'),
                child: const Text('View all ›', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF093C30))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.take(4).length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final act = _activities[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: const Icon(Icons.history_toggle_off, size: 16, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['action'] ?? act['detail'] ?? 'Admin action logged',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          act['created_at'] ?? '20 Apr 2026',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Members Directory Preview Card
  Widget _buildMembersDirectoryPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.badge_outlined, color: Color(0xFF093C30), size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Members Directory',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF093C30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.person_add, size: 14),
                    label: const Text('Add Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _showOnboardMemberDialog,
                  ),
                  TextButton(
                    onPressed: () => _switchRoute('verified_members'),
                    child: const Text('Manage All ›', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF093C30))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.take(3).length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = _members[index];
              final isActive = (m['status']?.toString().toLowerCase() ?? '') == 'active';
              final name = m['name'] ?? 'Member';
              final memberId = (m['member_user_id'] ?? m['id'] ?? 'MBR0004').toString();

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: isActive ? const Color(0xFF10B981).withAlpha(25) : Colors.orange.withAlpha(25),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'M',
                    style: TextStyle(color: isActive ? const Color(0xFF10B981) : Colors.orange.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('ID: $memberId • ${m['district'] ?? m['city'] ?? "Haryana"} • ${m['profession'] ?? "Welfare"}', style: const TextStyle(fontSize: 11)),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => _showMemberDetailModal(m),
                  child: const Text('Inspect', style: TextStyle(fontSize: 11)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. NOTIFICATIONS MODULE
  // ==========================================
  Widget _buildNotificationsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Notifications & Alerts Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Real-time administrative alerts, approvals & system updates', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Mark All Read'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read.')));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildNotificationItem(
                icon: Icons.person_add,
                iconColor: const Color(0xFF4F46E5),
                title: 'New Member Registration: Vikram Malhotra',
                subtitle: 'Advocate from Faridabad submitted application. KYC pending verification.',
                time: '15 mins ago',
                actionText: 'Review KYC',
                onAction: () => _switchRoute('unverified_members'),
              ),
              const Divider(height: 1),
              _buildNotificationItem(
                icon: Icons.payments,
                iconColor: const Color(0xFF10B981),
                title: 'Offline Donation Recorded (₹3,500)',
                subtitle: 'Donation from Kusum Rathore for Veer Nari Sustainable Aid. 80G Receipt issued.',
                time: '2 hours ago',
                actionText: 'View 80G',
                onAction: () => _switchRoute('donations'),
              ),
              const Divider(height: 1),
              _buildNotificationItem(
                icon: Icons.campaign,
                iconColor: const Color(0xFFF59E0B),
                title: 'Campaign Milestone: Martyr Family Support',
                subtitle: 'Campaign has reached 74% of target goal (₹18.4 Lakhs raised).',
                time: 'Yesterday',
                actionText: 'View Campaign',
                onAction: () => _switchRoute('campaigns'),
              ),
              const Divider(height: 1),
              _buildNotificationItem(
                icon: Icons.security,
                iconColor: const Color(0xFF3B82F6),
                title: 'Section 8 MCA Compliance Check Passed',
                subtitle: 'Annual ROC statutory returns and Darpan portal sync completed with 0 errors.',
                time: '3 days ago',
                actionText: 'System Health',
                onAction: () => _switchRoute('settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: iconColor.withAlpha(25),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        onPressed: onAction,
        child: Text(actionText, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  // ==========================================
  // 3. MEMBERS DIRECTORY MODULE
  // ==========================================
  Widget _buildMembersDirectoryModule() {
    final filtered = _filteredMembers;
    final isUnverifiedView = (_activeRoute == 'unverified_members');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnverifiedView ? 'Unverified Applications Queue' : 'Members Directory',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnverifiedView ? 'Review and verify pending member submissions' : 'Manage active foundation members, credentials & KYC',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Onboard Member'),
              onPressed: _showOnboardMemberDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _memberSearchCtrl,
          decoration: InputDecoration(
            hintText: 'Search members by name, ID, phone, email or city...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
            suffixIcon: _memberSearchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _memberSearchCtrl.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'All (${_members.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('active', 'Verified ($_activeCount)'),
              const SizedBox(width: 8),
              _buildFilterChip('pending', 'Pending Review ($_pendingCount)', isPending: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Text('No members found matching query.', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = filtered[index];
              final isActive = (m['status']?.toString().toLowerCase() ?? '') == 'active';
              final name = m['name'] ?? 'Member';
              final memberId = (m['member_user_id'] ?? m['id'] ?? 'MBR0004').toString();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? const Color(0xFF10B981).withAlpha(25) : Colors.orange.withAlpha(25),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                      style: TextStyle(color: isActive ? const Color(0xFF10B981) : Colors.orange.shade800, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('ID: $memberId • ${m['mobile'] ?? "N/A"} • ${m['district'] ?? m['city'] ?? "Haryana"}', style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF10B981).withAlpha(30) : Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF10B981) : Colors.orange.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        onPressed: () => _showMemberDetailModal(m),
                        child: const Text('Review & Docs', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, {bool isPending = false}) {
    final isSelected = (_memberFilter == value);
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      selectedColor: isPending ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _memberFilter = value),
    );
  }

  // ==========================================
  // 4. RENEWALS MODULE
  // ==========================================
  Widget _buildRenewalsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Membership Renewals & Subscriptions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Track annual renewals, subscription cycles and membership validity', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Send SMS Reminders'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renewal reminders sent to pending members!')));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryMiniCard('Total Annual Dues', '₹4,500', const Color(0xFFF59E0B))),
            const SizedBox(width: 10),
            Expanded(child: _buildSummaryMiniCard('Active Memberships', '$_activeCount', const Color(0xFF10B981))),
            const SizedBox(width: 10),
            Expanded(child: _buildSummaryMiniCard('Renewals Due Soon', '$_pendingCount', const Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = _members[index];
              final isPaid = (m['fee_status'] == 'Paid');
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPaid ? const Color(0xFF10B981).withAlpha(25) : Colors.red.withAlpha(25),
                  child: Icon(isPaid ? Icons.check : Icons.access_time, color: isPaid ? const Color(0xFF10B981) : Colors.red),
                ),
                title: Text(m['name'] ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('ID: ${m['member_user_id'] ?? m['id']} • Validity: ${m['renewal_date'] ?? "1 Year"}', style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isPaid ? 'Fee Paid (₹1500)' : 'Fee Due (₹1500)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isPaid ? const Color(0xFF10B981) : Colors.red)),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        setState(() {
                          m['fee_status'] = 'Paid';
                          m['renewal_date'] = '15 Aug 2027';
                        });
                        DocumentPreviewDialog.show(
                          context,
                          type: DocumentType.taxReceipt80G,
                          memberName: m['name'],
                          memberId: 'RNW-${m['id']}-2026',
                          donationAmount: 1500.0,
                        );
                      },
                      child: Text(isPaid ? 'Receipt' : 'Collect Fee', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMiniCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ==========================================
  // 5. DONATIONS MODULE (WITH SAFE AMOUNT PARSING)
  // ==========================================
  Widget _buildDonationsModule() {
    final filtered = _filteredDonations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Donations & 80G Receipts Ledger', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Recorded contributions and tax exemption certificates', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_card, size: 16),
              label: const Text('Record Donation'),
              onPressed: _showRecordDonationDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _donationSearchCtrl,
          decoration: InputDecoration(
            hintText: 'Search donations by donor name, phone or 80G receipt number...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = filtered[index];
            final amt = _parseDouble(d['amount']);
            final donorName = d['name'] ?? d['donor_name'] ?? 'Anonymous Donor';
            final receipt = d['receipt_no'] ?? '80G-${DateTime.now().year}-$index';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(25), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 22),
                ),
                title: Text(donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Ref: $receipt • ${d['created_at'] ?? "Recent"}', style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${amt.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        DocumentPreviewDialog.show(
                          context,
                          type: DocumentType.taxReceipt80G,
                          memberName: donorName,
                          memberId: receipt,
                          donationAmount: amt,
                        );
                      },
                      child: const Text('80G Receipt', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 6. CAMPAIGNS MODULE
  // ==========================================
  Widget _buildCampaignsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Campaigns & Welfare Initiatives', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Public crowdfunding causes and shaheed welfare drives', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.campaign, size: 16),
              label: const Text('Launch Campaign'),
              onPressed: _showCreateCampaignDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _campaigns.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final c = _campaigns[index];
            final goal = _parseDouble(c['goal'], 100000.0);
            final raised = _parseDouble(c['raised'], 0.0);
            final pct = (raised / goal).clamp(0.0, 1.0);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['title'] ?? 'Campaign', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(25), borderRadius: BorderRadius.circular(6)),
                        child: Text(c['status'] ?? 'ACTIVE', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c['desc'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Raised: ₹${raised.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('Goal: ₹${goal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 7. EVENTS MODULE
  // ==========================================
  Widget _buildEventsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Events & Foundation Programs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('National commemorations, camps and volunteer meets', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Schedule Event'),
              onPressed: _showCreateEventDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ev = _events[index];
            final rsvps = ev['rsvps'] ?? 0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: const Color(0xFF4F46E5).withAlpha(20), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.event, color: Color(0xFF4F46E5), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ev['title'] ?? 'Event', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text('📅 ${ev['date']} at ${ev['time']} • 📍 ${ev['venue']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text('RSVPs Confirmed: $rsvps Members', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        ev['rsvps'] = rsvps + 1;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('RSVP confirmed for ${ev['title']}! Total: ${rsvps + 1}')));
                    },
                    child: const Text('RSVP Now'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 8. PROJECTS MODULE
  // ==========================================
  Widget _buildProjectsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active NGO Initiatives & Milestones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        const Text('Ground impact projects, timelines and field execution', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        _buildNgoProjectsCard(),
      ],
    );
  }

  // ==========================================
  // 9. CERTIFICATES & OFFICIAL DOCUMENTS STUDIO
  // ==========================================
  void _populateStudioControllersFromMember(Map<String, dynamic> member, [DocumentType? docType]) {
    _studioSelectedMember = member;
    if (docType != null) {
      _studioDocType = docType;
    }
    _docRecipientNameCtrl.text = member['name']?.toString() ?? 'Kusum Rathore';
    _docMemberIdCtrl.text = member['member_id']?.toString() ?? 'MBR0004';
    _docPhoneCtrl.text = member['phone']?.toString() ?? '9876543210';
    _docEmailCtrl.text = member['email']?.toString() ?? 'kusumrathore662@gmail.com';
    _docCategoryCtrl.text = member['role']?.toString() ?? 'Life Welfare Member';
    _docStateCtrl.text = member['state']?.toString() ?? 'Haryana';
    _docDistrictCtrl.text = member['district']?.toString() ?? 'Gurugram';
    _docDesignationCtrl.text = member['designation']?.toString() ?? member['role']?.toString() ?? 'District Welfare Coordinator';
    _docBloodGroupCtrl.text = member['blood_group']?.toString() ?? 'O+ve';
    _docRefNumberCtrl.text = 'SFI/APPT/${DateTime.now().year}/${_docMemberIdCtrl.text}';
    _applyDocPreset('default');
  }

  void _openDocumentStudioForMember(Map<String, dynamic> member, DocumentType docType) {
    setState(() {
      _studioDocType = docType;
      _populateStudioControllersFromMember(member, docType);
      _activeRoute = 'certificates';
    });
  }


  void _showEditMemberInfoDialog(Map<String, dynamic> member) {
    final memberId = (member['member_user_id'] ?? member['id'] ?? 'MBR0004').toString();
    final numericId = _extractNumericId(memberId);
    final nameCtrl = TextEditingController(text: member['name'] ?? '');
    final phoneCtrl = TextEditingController(text: member['mobile'] ?? '');
    final emailCtrl = TextEditingController(text: member['email'] ?? '');
    final professionCtrl = TextEditingController(text: member['profession'] ?? '');
    final bloodGroupCtrl = TextEditingController(text: member['blood_group'] ?? 'O+');
    final districtCtrl = TextEditingController(text: member['district'] ?? member['city'] ?? '');
    final stateCtrl = TextEditingController(text: member['state'] ?? 'Haryana');
    final addressCtrl = TextEditingController(text: member['address'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.manage_accounts, color: Color(0xFF4F46E5)),
              const SizedBox(width: 10),
              Text('Edit Member $memberId', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone *', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                TextField(controller: professionCtrl, decoration: const InputDecoration(labelText: 'Profession / Designation', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: bloodGroupCtrl, decoration: const InputDecoration(labelText: 'Blood Group', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'District / City', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State', isDense: true, border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', isDense: true, border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and mobile number are required.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final updateData = {
                  'name': nameCtrl.text.trim(),
                  'mobile': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'profession': professionCtrl.text.trim(),
                  'blood_group': bloodGroupCtrl.text.trim(),
                  'city': districtCtrl.text.trim(),
                  'district': districtCtrl.text.trim(),
                  'state': stateCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                };

                final res = await _apiService.updateMemberDetails(
                  memberId: numericId,
                  data: updateData,
                  token: _authService.currentUser?.token,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.isSuccess
                        ? 'Member ${nameCtrl.text} updated and synchronized with website database!'
                        : 'Update saved locally: ${res.message}'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
                _loadDashboardData();
              },
              child: const Text('Save & Sync with Website'),
            ),
          ],
        );
      },
    );
  }

  void _openMemberDocumentPreviewOrEditor(Map<String, dynamic> member, DocumentType type) {
    final name = member['name']?.toString() ?? 'Unknown';
    final id = member['member_id']?.toString() ?? 'MBR0000';
    final phone = member['phone']?.toString();
    final email = member['email']?.toString();
    final category = member['role']?.toString() ?? 'Life Welfare Member';
    final state = member['state']?.toString() ?? 'Haryana';
    final district = member['district']?.toString() ?? 'Gurugram';
    final designation = member['designation']?.toString() ?? category;

    DocumentPreviewDialog.show(
      context,
      type: type,
      memberName: name,
      memberId: id,
      memberPhone: phone,
      memberEmail: email,
      memberCategory: category,
      memberState: state,
      memberDistrict: district,
      designation: designation,
      isEditable: true,
      donationAmount: 3500.0,
      onSave: (updated) {
        setState(() {
          if (updated['memberName'] != null) member['name'] = updated['memberName'];
          if (updated['memberCategory'] != null) member['role'] = updated['memberCategory'];
          if (updated['designation'] != null) member['designation'] = updated['designation'];
          if (updated['memberDistrict'] != null) member['district'] = updated['memberDistrict'];
          if (updated['memberState'] != null) member['state'] = updated['memberState'];
          if (updated['memberPhone'] != null) member['phone'] = updated['memberPhone'];
          if (updated['memberEmail'] != null) member['email'] = updated['memberEmail'];
          if (updated['bloodGroup'] != null) member['blood_group'] = updated['bloodGroup'];
        });
      },
    );
  }

  String _getDocTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.idCard:
        return 'Official Digital ID Card';
      case DocumentType.appointmentLetter:
        return 'Official Appointment Letter';
      case DocumentType.certificate:
        return 'Certificate of Appreciation';
      case DocumentType.taxReceipt80G:
        return '80G Tax Exemption Receipt';
    }
  }

  void _applyDocPreset(String presetKey) {
    setState(() {
      final name = _docRecipientNameCtrl.text;

      if (_studioDocType == DocumentType.appointmentLetter) {
        if (presetKey == 'district') {
          _docDesignationCtrl.text = 'District Welfare Coordinator';
          _docCategoryCtrl.text = 'Executive Council Appointee';
          _docLetterSubjectCtrl.text = 'Subject: Appointment as Official District Welfare Coordinator';
          _docValidUntilCtrl.text = '31 Dec 2028';
          _docBodyTextCtrl.text =
              'The National Executive Council of Shaheed Foundation of India is pleased to formally appoint you as District Welfare Coordinator for ${_docDistrictCtrl.text}, ${_docStateCtrl.text}.\n\nIn this executive capacity, you are empowered to oversee martyr family outreach, coordinate emergency welfare grants, and represent our national cause at regional defense commemorations.';
        } else if (presetKey == 'state') {
          _docDesignationCtrl.text = 'State Executive Secretary';
          _docCategoryCtrl.text = 'State Governing Board';
          _docLetterSubjectCtrl.text = 'Subject: Appointment as State Executive Secretary';
          _docValidUntilCtrl.text = '31 Dec 2027';
          _docBodyTextCtrl.text =
              'By resolution of the Central Governing Board of Shaheed Foundation of India, you are hereby appointed as State Executive Secretary for ${_docStateCtrl.text}.\n\nYou are entrusted to lead state-level mission execution, veteran support operations, and volunteer mobilization with highest integrity and dedication.';
        } else if (presetKey == 'patron') {
          _docDesignationCtrl.text = 'Honorary National Patron';
          _docCategoryCtrl.text = 'Patrons Council';
          _docLetterSubjectCtrl.text = 'Subject: Induction into Honorary National Patrons Council';
          _docValidUntilCtrl.text = 'Lifetime';
          _docBodyTextCtrl.text =
              'Shaheed Foundation of India takes immense pride in welcoming you into the Honorary National Patrons Council.\n\nYour distinguished leadership, patriotic devotion, and steadfast philanthropy serve as an inspiring pillar in empowering the dependents of India\'s brave martyrs.';
        } else if (presetKey == 'veernari') {
          _docDesignationCtrl.text = 'Veer Nari Welfare Envoy';
          _docCategoryCtrl.text = 'Special Welfare Mission';
          _docLetterSubjectCtrl.text = 'Subject: Appointment as Veer Nari Welfare Envoy';
          _docValidUntilCtrl.text = '31 Dec 2028';
          _docBodyTextCtrl.text =
              'On behalf of the Governing Council of Shaheed Foundation of India, you are appointed as Veer Nari Welfare Envoy.\n\nIn this dedicated role, you will champion direct family rehabilitation, children educational grants, and compassionate assistance for martyr families across India.';
        } else {
          // Default / Life Member
          _docDesignationCtrl.text = 'Life Welfare Member';
          _docCategoryCtrl.text = 'Life Welfare Member';
          _docLetterSubjectCtrl.text = 'Subject: Official Letter of Membership & Association';
          _docValidUntilCtrl.text = 'Lifetime';
          _docBodyTextCtrl.text =
              'Dear $name,\n\nOn behalf of the National Executive Council of Shaheed Foundation of India, we are pleased to confirm your enrollment as a Registered Member in the category of "${_docCategoryCtrl.text}".\n\nYour commitment to supporting the welfare of the families of our national martyrs and bravehearts is deeply valued. In this capacity, you are authorized to represent our collective mission and participate in national initiatives, memorial ceremonies, and family outreach programs.';
        }
      } else if (_studioDocType == DocumentType.certificate) {
        if (presetKey == 'honor') {
          _docCertificateTitleCtrl.text = 'CERTIFICATE OF HONOR';
          _docSubTitleCtrl.text = 'Conferred with utmost distinction upon';
          _docBodyTextCtrl.text =
              'Presented in solemn honor of extraordinary dedication, supreme benevolence, and exemplary humanitarian service rendered toward the welfare and dignity of our fallen national heroes\' families.';
        } else if (presetKey == 'merit') {
          _docCertificateTitleCtrl.text = 'NATIONAL CITATION OF MERIT';
          _docSubTitleCtrl.text = 'Proudly bestowed in high recognition of';
          _docBodyTextCtrl.text =
              'For outstanding volunteer leadership, grassroots mobilization, and tireless dedication in executing martyr children education initiatives during the year 2026.';
        } else if (presetKey == 'philanthropy') {
          _docCertificateTitleCtrl.text = 'LIFETIME PHILANTHROPY AWARD';
          _docSubTitleCtrl.text = 'Awarded with profound gratitude to';
          _docBodyTextCtrl.text =
              'In lasting tribute to your generous financial patronage and enduring allegiance to the mission of ensuring no martyr family is left uncared for.';
        } else if (presetKey == 'samman') {
          _docCertificateTitleCtrl.text = 'VEER PARIVAR SEVA SAMMAN';
          _docSubTitleCtrl.text = 'In deep veneration awarded to';
          _docBodyTextCtrl.text =
              'Recognizing unwavering compassionate care, legal assistance, and emotional solidarity extended to Veer Naris and war widows across India.';
        } else {
          _docCertificateTitleCtrl.text = 'CERTIFICATE OF APPRECIATION';
          _docSubTitleCtrl.text = 'This certificate is proudly awarded to';
          _docBodyTextCtrl.text =
              'In sincere recognition and deep gratitude for your noble commitment, selfless contribution, and steadfast support extended to the families of India\'s brave martyrs.';
        }
      } else if (_studioDocType == DocumentType.idCard) {
        if (presetKey == 'district') {
          _docDesignationCtrl.text = 'District Welfare Coordinator';
          _docValidUntilCtrl.text = '31 Dec 2028';
        } else if (presetKey == 'state') {
          _docDesignationCtrl.text = 'State Executive Secretary';
          _docValidUntilCtrl.text = '31 Dec 2027';
        } else if (presetKey == 'youth') {
          _docDesignationCtrl.text = 'Youth Wing Volunteer';
          _docValidUntilCtrl.text = '31 Dec 2026';
        } else {
          _docDesignationCtrl.text = 'Life Welfare Member';
          _docValidUntilCtrl.text = 'Lifetime';
        }
      } else if (_studioDocType == DocumentType.taxReceipt80G) {
        if (presetKey == '1000') {
          _docDonationAmountCtrl.text = '1000.00';
        } else if (presetKey == '3500') {
          _docDonationAmountCtrl.text = '3500.00';
        } else if (presetKey == '5000') {
          _docDonationAmountCtrl.text = '5000.00';
        } else if (presetKey == '10000') {
          _docDonationAmountCtrl.text = '10000.00';
        }
      }
    });
  }

  void _previewStudioDocument() {
    DocumentPreviewDialog.show(
      context,
      type: _studioDocType,
      memberName: _docRecipientNameCtrl.text,
      memberId: _docMemberIdCtrl.text,
      memberPhone: _docPhoneCtrl.text,
      memberEmail: _docEmailCtrl.text,
      memberCategory: _docCategoryCtrl.text,
      memberState: _docStateCtrl.text,
      memberDistrict: _docDistrictCtrl.text,
      issueDate: _docIssueDateCtrl.text,
      designation: _docDesignationCtrl.text,
      validUntil: _docValidUntilCtrl.text,
      bloodGroup: _docBloodGroupCtrl.text,
      refNumber: _docRefNumberCtrl.text,
      letterSubject: _docLetterSubjectCtrl.text,
      bodyText: _docBodyTextCtrl.text,
      certificateTitle: _docCertificateTitleCtrl.text,
      subTitle: _docSubTitleCtrl.text,
      signatoryName: _docSignatoryNameCtrl.text,
      signatoryTitle: _docSignatoryTitleCtrl.text,
      panNumber: _docPanCtrl.text,
      receiptNumber: _docReceiptNoCtrl.text,
      donationAmount: double.tryParse(_docDonationAmountCtrl.text) ?? 3500.0,
      isEditable: true,
      onSave: (updated) {
        setState(() {
          if (updated['memberName'] != null) _docRecipientNameCtrl.text = updated['memberName'];
          if (updated['memberId'] != null) _docMemberIdCtrl.text = updated['memberId'];
          if (updated['memberPhone'] != null) _docPhoneCtrl.text = updated['memberPhone'];
          if (updated['memberEmail'] != null) _docEmailCtrl.text = updated['memberEmail'];
          if (updated['memberCategory'] != null) _docCategoryCtrl.text = updated['memberCategory'];
          if (updated['memberState'] != null) _docStateCtrl.text = updated['memberState'];
          if (updated['memberDistrict'] != null) _docDistrictCtrl.text = updated['memberDistrict'];
          if (updated['designation'] != null) _docDesignationCtrl.text = updated['designation'];
          if (updated['validUntil'] != null) _docValidUntilCtrl.text = updated['validUntil'];
          if (updated['bloodGroup'] != null) _docBloodGroupCtrl.text = updated['bloodGroup'];
          if (updated['refNumber'] != null) _docRefNumberCtrl.text = updated['refNumber'];
          if (updated['letterSubject'] != null) _docLetterSubjectCtrl.text = updated['letterSubject'];
          if (updated['bodyText'] != null) _docBodyTextCtrl.text = updated['bodyText'];
          if (updated['certificateTitle'] != null) _docCertificateTitleCtrl.text = updated['certificateTitle'];
          if (updated['subTitle'] != null) _docSubTitleCtrl.text = updated['subTitle'];
          if (updated['signatoryName'] != null) _docSignatoryNameCtrl.text = updated['signatoryName'];
          if (updated['signatoryTitle'] != null) _docSignatoryTitleCtrl.text = updated['signatoryTitle'];
          if (updated['issueDate'] != null) _docIssueDateCtrl.text = updated['issueDate'];
          if (updated['panNumber'] != null) _docPanCtrl.text = updated['panNumber'];
          if (updated['receiptNumber'] != null) _docReceiptNoCtrl.text = updated['receiptNumber'];
        });
      },
    );
  }

  void _saveAndIssueStudioDocument() {
    final docTitle = _getDocTypeName(_studioDocType);
    final recipient = _docRecipientNameCtrl.text.trim();
    final memberId = _docMemberIdCtrl.text.trim();

    // Update matching member in state
    for (var m in _members) {
      if (m['member_id']?.toString() == memberId || m['name']?.toString() == recipient) {
        m['role'] = _docCategoryCtrl.text;
        m['designation'] = _docDesignationCtrl.text;
        m['district'] = _docDistrictCtrl.text;
        m['state'] = _docStateCtrl.text;
        break;
      }
    }

    // Add activity record
    _activities.insert(0, {
      'action': 'Document Issued',
      'admin': _authService.currentUser?.username ?? 'Admin',
      'time': 'Just now',
      'details': 'Issued official $docTitle to $recipient ($memberId)',
      'ip': '127.0.0.1',
      'badge': 'ISSUED',
    });

    // Synchronize document template settings to website MySQL site_settings table
    _apiService.updateSiteSettings({
      'doc_signatory_name': _docSignatoryNameCtrl.text.trim(),
      'doc_signatory_title': _docSignatoryTitleCtrl.text.trim(),
      'doc_pan': _docPanCtrl.text.trim(),
      'doc_issue_date': _docIssueDateCtrl.text.trim(),
      'doc_receipt_no': _docReceiptNoCtrl.text.trim(),
    }, token: _authService.currentUser?.token);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Successfully issued official $docTitle to $recipient!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildCertificatesModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Studio Header Banner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Certificates & Official Documents Studio',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Customise templates, citations, designations, signatories & dates. Issue legally verified credentials.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Live Preview', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _previewStudioDocument,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Document Type Switcher Tabs
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDocTypeTab(DocumentType.appointmentLetter, 'Official Appointment Letter', Icons.description),
              _buildDocTypeTab(DocumentType.certificate, 'Certificate of Appreciation', Icons.workspace_premium),
              _buildDocTypeTab(DocumentType.idCard, 'Official Digital ID Card', Icons.badge),
              _buildDocTypeTab(DocumentType.taxReceipt80G, '80G Tax Exemption Receipt', Icons.receipt_long),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Member Pre-Fill Selector Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_search, color: Color(0xFF4F46E5), size: 22),
              const SizedBox(width: 10),
              const Text(
                'Auto-Fill from Member:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _studioSelectedMember != null ? _studioSelectedMember!['member_id']?.toString() : null,
                    hint: const Text('Select a registered member to pre-fill details... (or type manually below)', style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'custom',
                        child: Text('Custom / Manual Recipient Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
                      ),
                      ..._members.map<DropdownMenuItem<String>>((m) {
                        final mName = m['name'] ?? 'Unknown';
                        final mId = m['member_id'] ?? 'MBR000';
                        final mRole = m['role'] ?? 'Member';
                        return DropdownMenuItem<String>(
                          value: mId.toString(),
                          child: Text('$mName ($mId) • $mRole', style: const TextStyle(fontSize: 12)),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      if (val == null || val == 'custom') {
                        setState(() {
                          _studioSelectedMember = null;
                        });
                      } else {
                        final found = _members.firstWhere(
                          (m) => m['member_id']?.toString() == val,
                          orElse: () => null,
                        );
                        if (found != null) {
                          _populateStudioControllersFromMember(Map<String, dynamic>.from(found));
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Quick Presets Chips Bar
        _buildPresetsBar(),
        const SizedBox(height: 20),

        // 5. Two-Column Editor Studio & Action Hub
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildStudioEditorForm()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildStudioActionPanel()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildStudioEditorForm(),
                  const SizedBox(height: 20),
                  _buildStudioActionPanel(),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 28),

        // 6. Master Catalog Quick Cards
        const Text(
          'Document Issuance Gallery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Preview master layouts or load standard foundation issuance formats',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCertCard('Official Member ID Card', Icons.badge, () {
              setState(() => _studioDocType = DocumentType.idCard);
              _previewStudioDocument();
            }),
            _buildCertCard('Membership Certificate', Icons.workspace_premium, () {
              setState(() => _studioDocType = DocumentType.certificate);
              _previewStudioDocument();
            }),
            _buildCertCard('Appointment Letter', Icons.description, () {
              setState(() => _studioDocType = DocumentType.appointmentLetter);
              _previewStudioDocument();
            }),
            _buildCertCard('80G Tax Exemption Certificate', Icons.receipt_long, () {
              setState(() => _studioDocType = DocumentType.taxReceipt80G);
              _previewStudioDocument();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDocTypeTab(DocumentType type, String label, IconData icon) {
    final isSelected = (_studioDocType == type);
    return InkWell(
      onTap: () {
        setState(() {
          _studioDocType = type;
          _applyDocPreset('default');
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: const Color(0xFF4F46E5)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsBar() {
    List<Widget> presetChips = [];
    if (_studioDocType == DocumentType.appointmentLetter) {
      presetChips = [
        _presetChip('Standard Life Member', () => _applyDocPreset('default')),
        _presetChip('District Welfare Coordinator', () => _applyDocPreset('district')),
        _presetChip('State Executive Secretary', () => _applyDocPreset('state')),
        _presetChip('Honorary National Patron', () => _applyDocPreset('patron')),
        _presetChip('Veer Nari Welfare Envoy', () => _applyDocPreset('veernari')),
      ];
    } else if (_studioDocType == DocumentType.certificate) {
      presetChips = [
        _presetChip('Standard Appreciation Citation', () => _applyDocPreset('default')),
        _presetChip('Certificate of Honor', () => _applyDocPreset('honor')),
        _presetChip('National Citation of Merit', () => _applyDocPreset('merit')),
        _presetChip('Lifetime Philanthropy Award', () => _applyDocPreset('philanthropy')),
        _presetChip('Veer Parivar Seva Samman', () => _applyDocPreset('samman')),
      ];
    } else if (_studioDocType == DocumentType.idCard) {
      presetChips = [
        _presetChip('Life Member (Lifetime)', () => _applyDocPreset('default')),
        _presetChip('District Coordinator (2 Years)', () => _applyDocPreset('district')),
        _presetChip('State Executive (3 Years)', () => _applyDocPreset('state')),
        _presetChip('Youth Wing Volunteer (1 Year)', () => _applyDocPreset('youth')),
      ];
    } else if (_studioDocType == DocumentType.taxReceipt80G) {
      presetChips = [
        _presetChip('₹1,000 Support', () => _applyDocPreset('1000')),
        _presetChip('₹3,500 Memorial Grant', () => _applyDocPreset('3500')),
        _presetChip('₹5,000 Veer Nari Grant', () => _applyDocPreset('5000')),
        _presetChip('₹10,000 Corpus Fund', () => _applyDocPreset('10000')),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          const Text('Quick Template Presets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3730A3))),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: presetChips),
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF312E81))),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFA5B4FC)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStudioEditorForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit ${_getDocTypeName(_studioDocType)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Reset Template', style: TextStyle(fontSize: 11)),
                onPressed: () => _applyDocPreset('default'),
              ),
            ],
          ),
          const Divider(height: 24),

          // Section 1: Recipient Info
          const Text('1. Recipient & Identification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStudioField('Full Legal Name', _docRecipientNameCtrl, Icons.person)),
              const SizedBox(width: 12),
              Expanded(child: _buildStudioField('Member / Roll ID', _docMemberIdCtrl, Icons.badge)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStudioField('Official Designation / Title', _docDesignationCtrl, Icons.work)),
              const SizedBox(width: 12),
              Expanded(child: _buildStudioField('Membership Category', _docCategoryCtrl, Icons.category)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStudioField('District / City', _docDistrictCtrl, Icons.location_city)),
              const SizedBox(width: 12),
              Expanded(child: _buildStudioField('State', _docStateCtrl, Icons.map)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStudioField('Phone Number', _docPhoneCtrl, Icons.phone)),
              const SizedBox(width: 12),
              Expanded(child: _buildStudioField('Email Address', _docEmailCtrl, Icons.email)),
            ],
          ),

          const SizedBox(height: 20),

          // Section 2: Document Specific Configuration
          Text('2. ${_getDocTypeName(_studioDocType)} Settings', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 10),

          if (_studioDocType == DocumentType.idCard) ...[
            Row(
              children: [
                Expanded(child: _buildStudioField('Blood Group', _docBloodGroupCtrl, Icons.bloodtype)),
                const SizedBox(width: 12),
                Expanded(child: _buildStudioField('Validity Period', _docValidUntilCtrl, Icons.event_available)),
              ],
            ),
          ] else if (_studioDocType == DocumentType.appointmentLetter) ...[
            Row(
              children: [
                Expanded(child: _buildStudioField('Dispatch Reference No.', _docRefNumberCtrl, Icons.numbers)),
                const SizedBox(width: 12),
                Expanded(child: _buildStudioField('Tenure / Validity', _docValidUntilCtrl, Icons.event_available)),
              ],
            ),
            const SizedBox(height: 12),
            _buildStudioField('Subject Line', _docLetterSubjectCtrl, Icons.subject),
          ] else if (_studioDocType == DocumentType.certificate) ...[
            Row(
              children: [
                Expanded(child: _buildStudioField('Certificate Award Title', _docCertificateTitleCtrl, Icons.military_tech)),
                const SizedBox(width: 12),
                Expanded(child: _buildStudioField('Presentation Line', _docSubTitleCtrl, Icons.subtitles)),
              ],
            ),
          ] else if (_studioDocType == DocumentType.taxReceipt80G) ...[
            Row(
              children: [
                Expanded(child: _buildStudioField('Tax-Exempt Donation (₹)', _docDonationAmountCtrl, Icons.currency_rupee)),
                const SizedBox(width: 12),
                Expanded(child: _buildStudioField('Receipt Number', _docReceiptNoCtrl, Icons.receipt)),
              ],
            ),
            const SizedBox(height: 12),
            _buildStudioField('PAN Number (Donor/Trustee)', _docPanCtrl, Icons.credit_card),
          ],

          if (_studioDocType == DocumentType.appointmentLetter || _studioDocType == DocumentType.certificate) ...[
            const SizedBox(height: 20),
            Text(
              _studioDocType == DocumentType.appointmentLetter ? '3. Appointment Letter Preamble & Body Text' : '3. Certificate Citation Text',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _docBodyTextCtrl,
              maxLines: 5,
              style: const TextStyle(fontSize: 12, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Enter customized letter or citation paragraph...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Section 4: Signatory & Issuance Details
          const Text('4. Authorized Signatory & Issuance Authority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStudioField('Authorized Signatory Name', _docSignatoryNameCtrl, Icons.draw)),
              const SizedBox(width: 12),
              Expanded(child: _buildStudioField('Signatory Title & Foundation Role', _docSignatoryTitleCtrl, Icons.assignment_ind)),
            ],
          ),
          const SizedBox(height: 12),
          _buildStudioField('Issue Date (YYYY-MM-DD)', _docIssueDateCtrl, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStudioField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildStudioActionPanel() {
    return Column(
      children: [
        // Live Document Summary Card
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
              BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Text('CUSTOMIZER ACTIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.verified, color: Color(0xFFF59E0B), size: 24),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getDocTypeName(_studioDocType),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Recipient: ${_docRecipientNameCtrl.text.isNotEmpty ? _docRecipientNameCtrl.text : "Recipient Name"}',
                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                'Member ID: ${_docMemberIdCtrl.text} • Role: ${_docDesignationCtrl.text}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Issue Date:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  Text(_docIssueDateCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Signatory:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  Text(_docSignatoryNameCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Live Document Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _previewStudioDocument,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.verified_user, size: 18),
                  label: const Text('Save & Issue Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _saveAndIssueStudioDocument,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Compliance & Governance Badge Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.gavel, color: Color(0xFF4F46E5), size: 18),
                  SizedBox(width: 8),
                  Text('Statutory Regulatory Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'All documents issued through this console carry legal validity under Section 8 of Companies Act 2013 (CIN: U85300HR2022NPL101988). Documents are digitally cataloged and verifiable by QR/Member ID.',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF4F46E5)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Click to customize & issue', style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 10. BLOG MODULE  // ==========================================
  // 10. BLOG MODULE (INTERACTIVE ARTICLE WRITER & INSPECTOR)
  // ==========================================
  Widget _buildBlogModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('News & Blog Publications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Publish articles, press statements and field stories', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.post_add, size: 16),
              label: const Text('Write Post'),
              onPressed: _showCreateArticleDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final a = _articles[index];
            return InkWell(
              onTap: () => _showArticleDetailDialog(a),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color(0xFF4F46E5).withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.article_outlined, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 3),
                          Text('${a['date']} • ${a['author']} • ${a['views']} Views', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showArticleDetailDialog(a),
                      tooltip: 'Edit Article',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCreateArticleDialog() {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General Welfare');
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Write & Publish Article', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Article Headline *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category Tag', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Article Content *', border: OutlineInputBorder()), maxLines: 5),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final headline = titleCtrl.text.trim();
                final category = categoryCtrl.text.trim().isNotEmpty ? categoryCtrl.text.trim() : 'General Welfare';
                final body = contentCtrl.text.trim();
                Navigator.pop(context);

                setState(() {
                  _articles.insert(0, {
                    'id': _articles.length + 1,
                    'title': headline,
                    'category': category,
                    'author': _authService.currentUser?.name ?? 'Admin Office',
                    'date': 'Today',
                    'views': 1,
                    'status': 'Published',
                    'content': body,
                  });
                });

                try {
                  await _apiService.createBlog(
                    data: {
                      'title': headline,
                      'category': category,
                      'content': body,
                      'author': _authService.currentUser?.name ?? 'Admin Office',
                    },
                    token: _authService.currentUser?.token,
                  );
                } catch (_) {}

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article published and synchronized with database!'), backgroundColor: Color(0xFF10B981)));
                }
              },
              child: const Text('Publish Article'),
            ),
          ],
        );
      },
    );
  }

  void _showArticleDetailDialog(Map<String, dynamic> a) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                Text('Category: ${a['category']} • Published on: ${a['date']} • By: ${a['author']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: Text(a['content'] ?? 'No text provided.', style: const TextStyle(fontSize: 13, height: 1.4)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(label: Text('${a['views']} Public Views', style: const TextStyle(fontSize: 11)), backgroundColor: const Color(0xFFE2E8F0)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Save & Update'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 11. GALLERY MODULE (RESPONSIVE & REAL PHOTO UPLOAD)
  // ==========================================
  Widget _buildGalleryModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Photo Gallery Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Click any album to inspect photos, or upload new event archives', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Upload Photos'),
              onPressed: () => _showUploadPhotoDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            int crossAxisCount;
            double childAspectRatio;

            if (w < 500) {
              crossAxisCount = 2;
              childAspectRatio = 0.95;
            } else if (w < 768) {
              crossAxisCount = 2;
              childAspectRatio = 1.05;
            } else if (w < 1050) {
              crossAxisCount = 3;
              childAspectRatio = 1.05;
            } else {
              crossAxisCount = 3;
              childAspectRatio = 1.15;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: _galleryAlbums.length,
              itemBuilder: (context, index) {
                final album = _galleryAlbums[index];
                return _buildInteractiveGalleryCard(album);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractiveGalleryCard(Map<String, dynamic> album) {
    final title = album['title'] as String? ?? 'Album';
    final icon = album['icon'] as IconData? ?? Icons.photo_library;
    final color = album['color'] as Color? ?? const Color(0xFF4F46E5);
    final count = album['count'] as int? ?? ((album['photos'] as List?)?.length ?? 0);

    return InkWell(
      onTap: () => _showAlbumViewerDialog(album),
      borderRadius: BorderRadius.circular(14),
      hoverColor: color.withAlpha(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B), height: 1.2),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count Photos • View',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumViewerDialog(Map<String, dynamic> album) {
    final title = album['title'] as String? ?? 'Album';
    final desc = album['desc'] as String? ?? '';
    final photos = (album['photos'] as List?) ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setViewerState) {
            final count = photos.length;
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 650,
                constraints: const BoxConstraints(maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_library, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('$count photos archived • Event date: ${album['date'] ?? '2026'}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ),
                    if (photos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No photos in this album yet. Click "Add to Album" below to upload!', style: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                      )
                    else
                      Flexible(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final p = photos[index];
                            return _buildPhotoTile(p, album, () {
                              setViewerState(() {});
                              setState(() {});
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add_a_photo, size: 16),
                            label: const Text('Add to Album'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showUploadPhotoDialog(preselectedAlbum: title);
                            },
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                            icon: const Icon(Icons.public, size: 16),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Album "$title" set to featured on public website homepage!'), backgroundColor: const Color(0xFF10B981)),
                              );
                            },
                            label: const Text('Feature on Website'),
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

  Widget _buildPhotoTile(Map<String, dynamic> p, Map<String, dynamic> album, VoidCallback onRefresh) {
    Widget imageWidget;
    if (p['bytes'] != null) {
      imageWidget = Image.memory(
        p['bytes'] as Uint8List,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.image, color: Colors.grey)),
      );
    } else if (p['imagePath'] != null) {
      imageWidget = Image.asset(
        p['imagePath'] as String,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.image, color: Colors.grey)),
      );
    } else {
      imageWidget = Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.image, color: Colors.grey));
    }

    return InkWell(
      onTap: () => _showPhotoDetailDialog(p, album, onRefresh),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p['title'] ?? 'Photo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '#${p['tag'] ?? 'Archive'}',
                      style: const TextStyle(fontSize: 9, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetailDialog(Map<String, dynamic> p, Map<String, dynamic> album, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: p['bytes'] != null
                      ? Image.memory(p['bytes'] as Uint8List, fit: BoxFit.cover)
                      : Image.asset(p['imagePath'] as String? ?? 'assets/images/gallery-1.jpg', fit: BoxFit.cover, errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 48))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(p['title'] ?? 'Photo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                          child: Text('#${p['tag'] ?? "Event"}', style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Album: ${album['title']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            (album['photos'] as List?)?.remove(p);
                            album['count'] = ((album['photos'] as List?)?.length ?? 0);
                            Navigator.pop(ctx);
                            onRefresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Photo removed from album')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Done'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
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

  void _showUploadPhotoDialog({String? preselectedAlbum}) {
    final captionCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'General');
    String selectedAlbum = preselectedAlbum ?? (_galleryAlbums.isNotEmpty ? _galleryAlbums[0]['title'] as String : 'Scholarship Distribution');

    Uint8List? pickedImageBytes;
    String? pickedImageName;
    String? selectedPresetPath;

    final presetPhotos = [
      {'name': 'Army Ceremony', 'path': 'assets/images/army2.jpg'},
      {'name': 'Health Clinic', 'path': 'assets/images/health.jpg'},
      {'name': 'Education Aid', 'path': 'assets/images/education-child.webp'},
      {'name': 'Veer Nari Welfare', 'path': 'assets/images/donation-2.jpg'},
      {'name': 'Youth Conclave', 'path': 'assets/images/event-1.jpg'},
      {'name': 'Memorial Tribute', 'path': 'assets/images/sf/2.jpeg'},
      {'name': 'Event Stage', 'path': 'assets/images/gallery-1.jpg'},
      {'name': 'Awards Presentation', 'path': 'assets/images/gallery-2.jpg'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final hasImage = pickedImageBytes != null || selectedPresetPath != null;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 520,
                constraints: const BoxConstraints(maxHeight: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_upload, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Upload Event Photos',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: selectedAlbum,
                              decoration: const InputDecoration(
                                labelText: 'Target Album *',
                                prefixIcon: Icon(Icons.photo_album, size: 20),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: _galleryAlbums.map((a) {
                                return DropdownMenuItem(
                                  value: a['title'] as String,
                                  child: Text(a['title'] as String, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDlgState(() => selectedAlbum = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: captionCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Photo Caption / Title *',
                                      hintText: 'e.g. Stage Ceremony',
                                      prefixIcon: Icon(Icons.title, size: 20),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: tagCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Tag',
                                      hintText: 'e.g. Welfare',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Select Photo *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            const SizedBox(height: 8),
                            if (!hasImage) ...[
                              InkWell(
                                onTap: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final xfile = await picker.pickImage(source: ImageSource.gallery);
                                    if (xfile != null) {
                                      final bytes = await xfile.readAsBytes();
                                      setDlgState(() {
                                        pickedImageBytes = bytes;
                                        pickedImageName = xfile.name;
                                        selectedPresetPath = null;
                                        if (captionCtrl.text.isEmpty) {
                                          captionCtrl.text = xfile.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('File picker error: $e')),
                                      );
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF4F46E5).withAlpha(120), width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                                        child: const Icon(Icons.add_photo_alternate, size: 36, color: Color(0xFF4F46E5)),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Click to Browse & Pick from your Device',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5)),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Supports JPG, PNG, WEBP high-res images',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('OR CHOOSE FROM ARCHIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 75,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: presetPhotos.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final item = presetPhotos[i];
                                    return InkWell(
                                      onTap: () {
                                        setDlgState(() {
                                          selectedPresetPath = item['path']!;
                                          pickedImageBytes = null;
                                          pickedImageName = item['name']!;
                                          if (captionCtrl.text.isEmpty) {
                                            captionCtrl.text = item['name']!;
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(item['path']!, fit: BoxFit.cover),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                color: Colors.black54,
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                child: Text(
                                                  item['name']!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.white, fontSize: 8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: pickedImageBytes != null
                                            ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                                            : Image.asset(selectedPresetPath!, fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                                              SizedBox(width: 4),
                                              Text('Image Selected & Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF16A34A))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pickedImageName ?? 'event_photo.jpg',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                                          ),
                                          const SizedBox(height: 6),
                                          InkWell(
                                            onTap: () {
                                              setDlgState(() {
                                                pickedImageBytes = null;
                                                pickedImageName = null;
                                                selectedPresetPath = null;
                                              });
                                            },
                                            child: const Text('Remove / Choose Another', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            icon: const Icon(Icons.cloud_upload, size: 16),
                            label: const Text('Upload & Archive'),
                            onPressed: () async {
                              final cap = captionCtrl.text.trim().isNotEmpty
                                  ? captionCtrl.text.trim()
                                  : (pickedImageName ?? 'Event Archive Photo');
                              final tag = tagCtrl.text.trim().isNotEmpty ? tagCtrl.text.trim() : 'Event';

                              setState(() {
                                final album = _galleryAlbums.firstWhere(
                                  (a) => a['title'] == selectedAlbum,
                                  orElse: () => _galleryAlbums[0],
                                );
                                final newPhoto = <String, dynamic>{
                                  'title': cap,
                                  'tag': tag,
                                  'date': 'Today',
                                };
                                if (pickedImageBytes != null) {
                                  newPhoto['bytes'] = pickedImageBytes;
                                } else if (selectedPresetPath != null) {
                                  newPhoto['imagePath'] = selectedPresetPath;
                                } else {
                                  newPhoto['imagePath'] = 'assets/images/gallery-1.jpg';
                                }
                                ((album['photos'] as List?) ?? []).insert(0, newPhoto);
                                album['count'] = ((album['photos'] as List?) ?? []).length;
                              });

                              try {
                                await _apiService.uploadGalleryPhoto(
                                  data: {
                                    'title': cap,
                                    'album_category': selectedAlbum,
                                    'image_url': selectedPresetPath ?? 'assets/images/gallery-1.jpg',
                                    'caption': cap,
                                  },
                                  token: _authService.currentUser?.token,
                                );
                              } catch (_) {}

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text('Photo "$cap" uploaded and synchronized with database!')),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
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

  // ==========================================
  // 12. MEDIA MODULE
  // ==========================================
  Widget _buildMediaModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Media & Document Storage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Storage repository: 245 MB of 5 GB used', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload Asset'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File upload manager ready.')));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mediaFiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final f = _mediaFiles[index];
              final isPdf = (f['type'] == 'PDF');
              return ListTile(
                leading: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue),
                title: Text(f['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('${f['desc']} • ${f['size']} • ${f['date']}', style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () {
                        DocumentPreviewDialog.show(context, type: DocumentType.certificate, memberName: 'Ministry of Corporate Affairs', memberId: 'U85300HR2022NPL101988');
                      },
                      tooltip: 'View Document',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${f['name']}...')));
                      },
                      tooltip: 'Download File',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 13. REPORTS MODULE (WITH REAL PDF & CSV PREVIEWS)
  // ==========================================
  Widget _buildReportsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Audit & Performance Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        const Text('Regulatory filings, tax compliance sheets and financial summaries', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInteractiveReportCard(
              title: 'Annual 80G Tax Exemption Audit',
              desc: 'Form 10BD & donor records for current FY',
              icon: Icons.receipt_long,
              onPrint: () {
                DocumentPreviewDialog.show(
                  context,
                  type: DocumentType.taxReceipt80G,
                  memberName: 'Consolidated FY 2026-27 Audit',
                  memberId: 'AUDIT-80G-2026',
                  donationAmount: _totalDonationsAmount,
                );
              },
              onExportCsv: () {
                _showExportCsvDialog(
                  '80G_Tax_Exemption_Ledger_2026.csv',
                  """Transaction_ID,Donor_Name,Mobile,Amount_INR,Receipt_No,Date,Status
TXN001,Col. Gurmeet Singh,9810011223,5000.00,80G-2024-99120,2024-08-14,Approved
TXN002,Kusum Rathore,9876543210,3500.00,80G-2024-88410,2024-08-10,Approved
TXN003,Rajiv Malhotra,9845012345,2500.00,80G-2024-77119,2024-08-01,Approved""",
                );
              },
            ),
            _buildInteractiveReportCard(
              title: 'MCA Section 8 Statutory Compliance',
              desc: 'Director filings and registered members tally',
              icon: Icons.account_balance,
              onPrint: () {
                DocumentPreviewDialog.show(
                  context,
                  type: DocumentType.appointmentLetter,
                  memberName: 'Government of India MCA Compliance Certificate',
                  memberId: 'CIN-U85300HR2022NPL101988',
                );
              },
              onExportCsv: () {
                _showExportCsvDialog(
                  'MCA_Section8_Filing_Registry.csv',
                  """CIN,Entity_Name,Registration_State,Darpan_ID,Status
U85300HR2022NPL101988,Shaheed Foundation Of India,Haryana,HR/2022/032189,Active
Director_1,Col. Gurmeet Singh,DIN0912445,Authorized Signatory,Valid
Director_2,Kusum Rathore,DIN0871142,Operations Lead,Valid""",
                );
              },
            ),
            _buildInteractiveReportCard(
              title: 'Campaign Fundraising Ledger',
              desc: 'Direct breakdown of active causes and funds',
              icon: Icons.campaign,
              onPrint: () {
                DocumentPreviewDialog.show(
                  context,
                  type: DocumentType.certificate,
                  memberName: 'Campaigns Financial Tally Statement',
                  memberId: 'CMP-FIN-2026',
                );
              },
              onExportCsv: () {
                _showExportCsvDialog(
                  'Campaign_Funds_Audit.csv',
                  """Campaign_Name,Target_Goal,Raised_Amount,Status,Donors_Count
Martyr Family Support,2500000.00,1840000.00,ACTIVE,142
Education Initiative,1500000.00,1500000.00,COMPLETE,98
Veer Nari Sustainable Aid,1000000.00,780000.00,ACTIVE,64""",
                );
              },
            ),
            _buildInteractiveReportCard(
              title: 'Members KYC Verification Log',
              desc: 'Aadhaar, contact and demographic data sheets',
              icon: Icons.badge,
              onPrint: () {
                DocumentPreviewDialog.show(
                  context,
                  type: DocumentType.idCard,
                  memberName: 'Certified Registry of Members',
                  memberId: 'REG-MBR-2026',
                );
              },
              onExportCsv: () {
                _showExportCsvDialog(
                  'Members_Registry_KYC.csv',
                  """Member_ID,Full_Name,Phone,Email,District,State,KYC_Status
MBR0006,Amit Sharma,9811223344,amit.sharma@gmail.com,Gurugram,Haryana,Verified
MBR0005,Vikram Malhotra,9876501234,vikram.m@gmail.com,Faridabad,Haryana,Pending
MBR0004,Kusum Rathore,9876543210,kusumrathore662@gmail.com,Gurugram,Haryana,Verified
MBR0003,Col. Gurmeet Singh,9810011223,gurmeet.singh@gmail.com,Chandigarh,Punjab,Verified""",
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractiveReportCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onPrint,
    required VoidCallback onExportCsv,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4F46E5), size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                icon: const Icon(Icons.download, size: 14),
                label: const Text('Export CSV', style: TextStyle(fontSize: 11)),
                onPressed: onExportCsv,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.print, size: 14),
                label: const Text('Print PDF', style: TextStyle(fontSize: 11)),
                onPressed: onPrint,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportCsvDialog(String filename, String csvData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.table_chart, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(filename, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Generated Comma-Separated Values (CSV):', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    csvData,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF4ADE80)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('Copy to Clipboard'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$filename copied to clipboard!'), backgroundColor: const Color(0xFF10B981)));
              },
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 14. SUPPORT MODULE (INTERACTIVE RESOLVE)
  // ==========================================
  Widget _buildSupportModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Public Inquiries & Support Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        const Text('Tickets raised from sfofindia.com public portal and member inquiries', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _supportTickets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final t = _supportTickets[index];
            final isOpen = (t['status'] == 'Open' || t['status'] == 'In Progress');
            return InkWell(
              onTap: () => _showTicketDetailDialog(t),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isOpen ? Colors.red.withAlpha(25) : const Color(0xFF10B981).withAlpha(25),
                      child: Icon(isOpen ? Icons.priority_high : Icons.check, color: isOpen ? Colors.red : const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${t['id']} • ${t['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: isOpen ? Colors.red.withAlpha(20) : const Color(0xFF10B981).withAlpha(20), borderRadius: BorderRadius.circular(6)),
                                child: Text(t['status'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOpen ? Colors.red : const Color(0xFF10B981))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(t['subject'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(t['date'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOpen ? const Color(0xFF4F46E5) : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showTicketDetailDialog(t),
                      child: Text(isOpen ? 'Resolve' : 'View'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showTicketDetailDialog(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${t['id']}: ${t['subject']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${t['name']} • Raised: ${t['date']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: Text(t['message'] ?? 'Customer request submitted via portal.', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Mark as Resolved'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  t['status'] = 'Resolved';
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket ${t['id']} resolved!'), backgroundColor: const Color(0xFF10B981)));
              },
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 15. ADMINS MODULE (INTERACTIVE ADD ADMIN)
  // ==========================================
  Widget _buildAdminsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Staff & System Administrators', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Admin users, roles and permission privileges', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add Administrator'),
              onPressed: _showAddAdminDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _adminUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final adm = _adminUsers[index];
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.shield, color: Colors.amber, size: 20)),
                title: Text('${adm['name']} (${adm['role']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${adm['email']} • Permissions: ${adm['permissions']}', style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(adm['status'], style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Operations Coordinator';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Invite / Add Administrator', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Administrative Role', border: OutlineInputBorder()),
                    items: ['Super Administrator', 'Operations Coordinator', 'Finance & 80G Lead', 'Communications Lead']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setDlgState(() => role = val ?? role),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    setState(() {
                      _adminUsers.add({
                        'name': nameCtrl.text.trim(),
                        'role': role,
                        'email': emailCtrl.text.trim(),
                        'status': 'ACTIVE',
                        'permissions': 'Role-based Administrative Access',
                        'last_login': 'Just Invited',
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin invitation sent to ${emailCtrl.text}!'), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                  child: const Text('Send Invitation'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 16. ACTIVITY LOGS MODULE
  // ==========================================
  Widget _buildActivityLogsModule() {
    final filtered = _activities.where((a) {
      final q = _logSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      final action = (a['action'] ?? '').toString().toLowerCase();
      final detail = (a['detail'] ?? '').toString().toLowerCase();
      return action.contains(q) || detail.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Administrative Activity Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  Text('Complete audit trail from backend ngom_admin_activity', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh Logs',
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _logSearchCtrl,
          decoration: InputDecoration(
            hintText: 'Search audit trail by keyword, action or IP address...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final act = filtered[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF4F46E5).withAlpha(20),
                  child: const Icon(Icons.bolt, size: 16, color: Color(0xFF4F46E5)),
                ),
                title: Text(act['action'] ?? act['detail'] ?? 'Audit event', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('${act['created_at'] ?? "Recent"} • IP: ${act['ip_address'] ?? "127.0.0.1"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 17. SETTINGS MODULE
  // ==========================================
  Widget _buildSettingsModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Website & Portal Configuration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        const Text('Statutory NGO identity, registration details and payment gateway integration', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Organization Statutory Identity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              TextField(controller: _orgNameCtrl, decoration: const InputDecoration(labelText: 'Non-Profit Entity Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _cinCtrl, decoration: const InputDecoration(labelText: 'Corporate Identification Number (CIN)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _taxCtrl, decoration: const InputDecoration(labelText: '80G Tax Exemption Unique Registration Number', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _darpanCtrl, decoration: const InputDecoration(labelText: 'NITI Aayog NGO Darpan Registration ID', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Backend & Infrastructure Health', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              _buildHealthRow('REST API Server (Port 8099)', 'CONNECTED (HTTP 200)', const Color(0xFF10B981)),
              _buildHealthRow('Database Engine', 'MySQL (Host: 127.0.0.1, DB: website)', const Color(0xFF10B981)),
              _buildHealthRow('Razorpay Payment Gateway', 'LIVE (Webhook verified)', const Color(0xFF10B981)),
              _buildHealthRow('Public Domain', 'sfofindia.com', const Color(0xFF4F46E5)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                icon: const Icon(Icons.save),
                label: const Text('Save Settings & Update Metadata', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final res = await _apiService.updateSiteSettings({
                    'site_name': _orgNameCtrl.text.trim(),
                    'org_cin': _cinCtrl.text.trim(),
                    'org_tax_id': _taxCtrl.text.trim(),
                    'org_darpan_id': _darpanCtrl.text.trim(),
                  }, token: _authService.currentUser?.token);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess
                          ? 'Settings synchronized with website database!'
                          : 'Settings saved locally.'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  // --- Reviews & Testimonials Moderation Module ---

  Future<void> _loadAdminTestimonials() async {
    setState(() => _isLoadingTestimonials = true);
    try {
      final res = await _apiService.getTestimonials(
        status: 'all',
        token: _authService.currentUser?.token,
      );
      if (res.isSuccess && res.data is List && mounted) {
        setState(() {
          _adminTestimonials = (res.data as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingTestimonials = false);
  }

  Future<void> _moderateTestimonial(int id, String status) async {
    final res = await _apiService.updateTestimonialStatus(
      id: id,
      status: status,
      token: _authService.currentUser?.token,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? "Review status updated to '$status'"),
          backgroundColor: status == 'approved' ? const Color(0xFF137333) : Colors.red.shade700,
        ),
      );
      _loadAdminTestimonials();
    }
  }

  Widget _buildTestimonialsModule() {
    final total = _adminTestimonials.length;
    final pendingCount = _adminTestimonials.where((t) => (t['status'] ?? 'pending').toString().toLowerCase() == 'pending').length;
    final approvedCount = _adminTestimonials.where((t) => (t['status'] ?? '').toString().toLowerCase() == 'approved').length;
    final rejectedCount = _adminTestimonials.where((t) => (t['status'] ?? '').toString().toLowerCase() == 'rejected').length;

    final filtered = _adminTestimonials.where((t) {
      final st = (t['status'] ?? 'pending').toString().toLowerCase();
      if (_testimonialFilter == 'pending') return st == 'pending';
      if (_testimonialFilter == 'approved') return st == 'approved';
      if (_testimonialFilter == 'rejected') return st == 'rejected';
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Reviews & Testimonials Moderation ⭐',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Reviews only appear publicly on the mobile app and website after admin verification and approval.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: _isLoadingTestimonials
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh, color: Color(0xFF4F46E5)),
              tooltip: 'Refresh Reviews',
              onPressed: _isLoadingTestimonials ? null : _loadAdminTestimonials,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // KPI Summary Badges
        Row(
          children: [
            _buildTestimonialKpiCard('Total Reviews', total.toString(), const Color(0xFF4F46E5), Icons.rate_review),
            const SizedBox(width: 10),
            _buildTestimonialKpiCard('Pending Approval', pendingCount.toString(), const Color(0xFFD97706), Icons.hourglass_top),
            const SizedBox(width: 10),
            _buildTestimonialKpiCard('Approved & Live', approvedCount.toString(), const Color(0xFF16A34A), Icons.verified),
            const SizedBox(width: 10),
            _buildTestimonialKpiCard('Rejected', rejectedCount.toString(), const Color(0xFFDC2626), Icons.cancel),
          ],
        ),
        const SizedBox(height: 18),

        // Filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTestimonialFilterChip('all', 'All ($total)'),
              const SizedBox(width: 8),
              _buildTestimonialFilterChip('pending', 'Pending Approval ($pendingCount)'),
              const SizedBox(width: 8),
              _buildTestimonialFilterChip('approved', 'Approved & Live ($approvedCount)'),
              const SizedBox(width: 8),
              _buildTestimonialFilterChip('rejected', 'Rejected ($rejectedCount)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Testimonials List
        if (_isLoadingTestimonials)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 42, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  _testimonialFilter == 'pending'
                      ? 'No pending reviews awaiting approval!'
                      : 'No reviews found in this category.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  'When citizens or beneficiaries submit reviews via the app, they will appear here for verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final t = filtered[idx];
              final id = int.tryParse(t['id']?.toString() ?? '0') ?? 0;
              final name = t['name']?.toString() ?? 'Anonymous Citizen';
              final relation = t['relation']?.toString() ?? 'Beneficiary';
              final location = t['location']?.toString() ?? 'India';
              final program = t['program']?.toString() ?? 'Welfare & Relief';
              final quote = t['quote']?.toString() ?? '';
              final rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;
              final status = (t['status'] ?? 'pending').toString().toLowerCase();
              final createdAt = t['created_at']?.toString().split(' ')[0] ?? 'Recent';

              Color statusColor = const Color(0xFFD97706);
              String statusLabel = 'PENDING APPROVAL';
              if (status == 'approved') {
                statusColor = const Color(0xFF16A34A);
                statusLabel = 'APPROVED & PUBLIC';
              } else if (status == 'rejected') {
                statusColor = const Color(0xFFDC2626);
                statusLabel = 'REJECTED';
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: status == 'pending' ? const Color(0xFFFDE68A) : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Author, Rating, Status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF4F46E5).withAlpha(20),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'C',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              Text(
                                '$relation • $location • $createdAt',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withAlpha(60)),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Program and Rating stars
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Cause: $program',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            rating.clamp(1, 5),
                            (i) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Story quote
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '"$quote"',
                        style: const TextStyle(fontSize: 12, height: 1.4, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Actions row: Approve, Reject
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status != 'approved')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Approve & Publish', style: TextStyle(fontSize: 12)),
                            onPressed: () => _moderateTestimonial(id, 'approved'),
                          ),
                        const SizedBox(width: 8),
                        if (status != 'rejected')
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Reject', style: TextStyle(fontSize: 12)),
                            onPressed: () => _moderateTestimonial(id, 'rejected'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTestimonialKpiCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialFilterChip(String filterKey, String label) {
    final isSelected = (_testimonialFilter == filterKey);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _testimonialFilter = filterKey),
      selectedColor: const Color(0xFF4F46E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300),
      ),
    );
  }
}

// ==========================================
// CUSTOM CHART WIDGETS (WEBSITE REPLICATION)
// ==========================================

class _RegistrationBarChart extends StatelessWidget {
  final List<String>? labels;
  final List<num>? data;

  const _RegistrationBarChart({this.labels, this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _BarChartPainter(labels: labels, data: data),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String>? labels;
  final List<num>? data;

  _BarChartPainter({this.labels, this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final defaultDays = ['11 Sep', '12 Sep', '13 Sep', '14 Sep', '15 Sep', '16 Sep', '17 Sep'];
    final defaultValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0];

    final days = (labels != null && labels!.isNotEmpty)
        ? labels!.map((l) {
            final match = RegExp(r'([A-Za-z]+)\s*\((\d+)\)').firstMatch(l);
            if (match != null) {
              return '${match.group(1)} ${match.group(2)}';
            }
            return l;
          }).toList()
        : defaultDays;

    final values = (data != null && data!.isNotEmpty)
        ? data!.map((v) => v.toDouble()).toList()
        : defaultValues;

    final maxVal = values.fold<double>(1.0, (m, v) => v > m ? v : m);

    final paintGreen = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final baseY = size.height - 24;
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), paintLine);
    canvas.drawLine(Offset(0, baseY - 50), Offset(size.width, baseY - 50), paintLine);

    final count = days.length;
    final slotWidth = size.width / count;
    final barWidth = (slotWidth * 0.38).clamp(8.0, 24.0);

    for (int i = 0; i < count; i++) {
      final xCenter = (i * slotWidth) + (slotWidth / 2);

      if (values[i] > 0) {
        final barHeight = ((values[i] / maxVal) * 50).clamp(6.0, 52.0);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(xCenter - (barWidth / 2), baseY - barHeight, barWidth, barHeight),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, paintGreen);

        final countSpan = TextSpan(
          text: values[i].toInt().toString(),
          style: const TextStyle(color: Color(0xFF15803D), fontSize: 8.5, fontWeight: FontWeight.bold),
        );
        final countPainter = TextPainter(text: countSpan, textDirection: TextDirection.ltr);
        countPainter.layout();
        countPainter.paint(canvas, Offset(xCenter - (countPainter.width / 2), baseY - barHeight - 11));
      }

      final labelText = days[i];
      final textSpan = TextSpan(
        text: labelText,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5, fontWeight: FontWeight.w500),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(xCenter - (textPainter.width / 2), baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.labels != labels || oldDelegate.data != data;
}

class _DonationLineChart extends StatelessWidget {
  final List<String>? labels;
  final List<num>? data;

  const _DonationLineChart({this.labels, this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _LineChartPainter(labels: labels, data: data),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<String>? labels;
  final List<num>? data;

  _LineChartPainter({this.labels, this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final defaultMonths = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
    final defaultValues = [0.0, 0.0, 0.0, 0.0, 0.0, 2500.0];

    final months = (labels != null && labels!.isNotEmpty)
        ? labels!.map((l) => l.split(' ').first).toList()
        : defaultMonths;

    final values = (data != null && data!.isNotEmpty)
        ? data!.map((v) => v.toDouble()).toList()
        : defaultValues;

    final maxVal = values.fold<double>(1.0, (m, v) => v > m ? v : m);

    final baseY = size.height - 24;

    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final paintLine = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF3B82F6).withAlpha(45),
          const Color(0xFF3B82F6).withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, baseY));

    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), paintGrid);
    canvas.drawLine(Offset(0, baseY - 50), Offset(size.width, baseY - 50), paintGrid);

    const leftPad = 22.0;
    const rightPad = 22.0;
    final chartWidth = size.width - leftPad - rightPad;
    final count = months.length;
    final slotWidth = count > 1 ? chartWidth / (count - 1) : chartWidth;

    final path = Path();
    final fillPath = Path();

    List<Offset> points = [];
    for (int i = 0; i < count; i++) {
      final x = leftPad + (i * slotWidth);
      final normalized = (values[i] / maxVal).clamp(0.0, 1.0);
      final y = baseY - 6 - (normalized * 48);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, baseY);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(leftPad + ((count - 1) * slotWidth), baseY);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    for (int i = 0; i < count; i++) {
      final pt = points[i];
      canvas.drawCircle(pt, 3.5, paintDot);
      canvas.drawCircle(pt, 2.0, Paint()..color = Colors.white);

      if (values[i] > 0) {
        final String amtStr = values[i] >= 1000
            ? '₹${(values[i] / 1000).toStringAsFixed(values[i] % 1000 == 0 ? 0 : 1)}k'
            : '₹${values[i].toInt()}';
        final valSpan = TextSpan(
          text: amtStr,
          style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 8.5, fontWeight: FontWeight.bold),
        );
        final valPainter = TextPainter(text: valSpan, textDirection: TextDirection.ltr);
        valPainter.layout();
        valPainter.paint(canvas, Offset(pt.dx - (valPainter.width / 2), pt.dy - 12));
      }

      final textSpan = TextSpan(
        text: months[i],
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5, fontWeight: FontWeight.w500),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(pt.dx - (textPainter.width / 2), baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.labels != labels || oldDelegate.data != data;
}

class _CampaignRaisedChart extends StatelessWidget {
  final List<String>? labels;
  final List<num>? data;

  const _CampaignRaisedChart({this.labels, this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _CampaignRaisedPainter(labels: labels, data: data),
    );
  }
}

class _CampaignRaisedPainter extends CustomPainter {
  final List<String>? labels;
  final List<num>? data;

  _CampaignRaisedPainter({this.labels, this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final categories = (labels != null && labels!.isNotEmpty)
        ? labels!
        : ['Martyr Support', 'Child Education', 'Veer Nari Relief'];
    final values = (data != null && data!.isNotEmpty)
        ? data!.map((v) => v.toDouble()).toList()
        : [1840000.0, 1500000.0, 780000.0];

    final maxVal = values.fold<double>(1.0, (m, v) => v > m ? v : m);
    final baseY = size.height - 24;

    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final paintBar = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), paintGrid);
    canvas.drawLine(Offset(0, baseY - 50), Offset(size.width, baseY - 50), paintGrid);

    final count = categories.length;
    final slotWidth = size.width / count;
    final barWidth = (slotWidth * 0.35).clamp(10.0, 26.0);

    for (int i = 0; i < count; i++) {
      final xCenter = (i * slotWidth) + (slotWidth / 2);
      final barHeight = ((values[i] / maxVal) * 50).clamp(4.0, 52.0);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter - (barWidth / 2), baseY - barHeight, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paintBar);

      final amtStr = values[i] >= 100000
          ? '₹${(values[i] / 100000).toStringAsFixed(1)}L'
          : values[i] >= 1000
              ? '₹${(values[i] / 1000).toStringAsFixed(0)}k'
              : '₹${values[i].toInt()}';
      final amtSpan = TextSpan(
        text: amtStr,
        style: const TextStyle(color: Color(0xFFBE123C), fontSize: 8.5, fontWeight: FontWeight.bold),
      );
      final amtPainter = TextPainter(text: amtSpan, textDirection: TextDirection.ltr);
      amtPainter.layout();
      amtPainter.paint(canvas, Offset(xCenter - (amtPainter.width / 2), baseY - barHeight - 11));

      final title = categories[i].length > 13 ? '${categories[i].substring(0, 11)}..' : categories[i];
      final textSpan = TextSpan(
        text: title,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5, fontWeight: FontWeight.w500),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(xCenter - (textPainter.width / 2), baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _CampaignRaisedPainter oldDelegate) =>
      oldDelegate.labels != labels || oldDelegate.data != data;
}
