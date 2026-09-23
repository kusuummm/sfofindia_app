import 'package:flutter/material.dart';
import '../models/service_program.dart';
import '../models/donation_model.dart';
import '../models/member_model.dart';
import '../models/document_model.dart';
import '../models/gallery_event_model.dart';
import '../models/memorial_hero_model.dart';
import '../models/welfare_scheme_model.dart';



class TeamMember {
  final String name;
  final String role;
  final String description;
  final String imagePath;

  const TeamMember({
    required this.name,
    required this.role,
    required this.description,
    required this.imagePath,
  });
}

class TestimonialItem {
  final String id;
  final String name;
  final String relation;
  final String location;
  final String quote;
  final String program;
  final String imagePath;
  final String impactBadge;
  final int rating;
  final String status;
  final String? createdAt;

  const TestimonialItem({
    required this.id,
    required this.name,
    required this.relation,
    required this.location,
    required this.quote,
    required this.program,
    required this.imagePath,
    this.impactBadge = 'Verified Beneficiary',
    this.rating = 5,
    this.status = 'approved',
    this.createdAt,
  });

  factory TestimonialItem.fromJson(Map<String, dynamic> json) {
    return TestimonialItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Citizen Beneficiary',
      relation: json['relation']?.toString() ?? 'Beneficiary',
      location: json['location']?.toString() ?? 'India',
      quote: json['quote']?.toString() ?? '',
      program: json['program']?.toString() ?? 'Welfare & Relief',
      imagePath: json['image']?.toString() ?? 'assets/images/team-1.jpg',
      impactBadge: json['impact_badge']?.toString() ?? 'Verified Beneficiary',
      rating: int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'location': location,
      'quote': quote,
      'program': program,
      'image': imagePath,
      'impact_badge': impactBadge,
      'rating': rating,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String category;
  final String date;
  final String readTime;
  final String summary;
  final String content;
  final String imagePath;
  final String author;
  final int views;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.readTime,
    required this.summary,
    required this.content,
    required this.imagePath,
    this.author = 'Shaheed Foundation Bureau',
    this.views = 1240,
  });
}


class RegisteredBloodDonor {
  final String id;
  final String fullName;
  final String bloodGroup;
  final String phone;
  final String city;
  final String state;
  final String lastDonationDate;
  final bool isAvailable;

  RegisteredBloodDonor({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.phone,
    required this.city,
    required this.state,
    this.lastDonationDate = 'Never / First Time',
    this.isAvailable = true,
  });
}

class AidApplicationRecord {
  final String referenceId;
  final String applicantName;
  final String phone;
  final String email;
  final String martyrName;
  final String relation;
  final String program;
  final String address;
  final String details;
  final String status;
  final DateTime appliedDate;

  AidApplicationRecord({
    required this.referenceId,
    required this.applicantName,
    required this.phone,
    required this.email,
    required this.martyrName,
    required this.relation,
    required this.program,
    required this.address,
    required this.details,
    this.status = 'Under Verification',
    DateTime? appliedDate,
  }) : appliedDate = appliedDate ?? DateTime.now();
}


class AppRepository extends ChangeNotifier {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  // Programs / Services
  final List<ServiceProgram> services = [
    const ServiceProgram(
      id: 'financial',
      title: 'Financial Assistance',
      subtitle: 'Emergency grants & sustainable family aid',
      description:
          'Shaheed Foundation of India offers direct monthly financial stipends, emergency relief grants, and debt-relief assistance to the surviving spouses and elderly parents of martyrs.',
      imagePath: 'assets/images/donation-1.jpg',
      icon: Icons.volunteer_activism,
      benefits: [
        'Monthly sustenance stipend for martyr widows & dependent parents',
        'Emergency medical grant up to ₹1,00,000 for critical surgeries',
        'Guidance on government ex-gratia, pension & defense welfare claims',
        'Direct bank transfers with 100% transparency'
      ],
      eligibleCriteria: [
        'Legal dependents of fallen armed forces, paramilitary, or police personnel',
        'Valid verification of martyr service records',
        'Income threshold verification for priority assistance'
      ],
    ),
    const ServiceProgram(
      id: 'education',
      title: "Children's Education Support",
      subtitle: 'Empowering future generations through knowledge',
      description:
          'Ensuring every child of a martyr has uncompromised access to top-tier schooling, higher education, coaching for competitive exams, laptops, and study materials.',
      imagePath: 'assets/images/education-child.webp',
      icon: Icons.school,
      benefits: [
        'Full reimbursement of school, college, and university tuition fees',
        'Free distribution of school bags, textbooks, uniforms, and digital tablets',
        'Sponsorship for UPSC, NDA, CDS, JEE, and NEET coaching programs',
        'Merit scholarships for outstanding academic excellence'
      ],
      eligibleCriteria: [
        'Children of martyrs enrolled in recognized educational institutions',
        'Age limit up to 25 years for higher education programs',
        'Continuous semester performance review'
      ],
    ),
    const ServiceProgram(
      id: 'medical',
      title: 'Medical & Healthcare',
      subtitle: 'Comprehensive healthcare for martyr dependents',
      description:
          'From monthly prescription support for elderly parents to emergency hospitalization and mental health trauma counseling, we stand with families in their health crises.',
      imagePath: 'assets/images/health.jpg',
      icon: Icons.health_and_safety,
      benefits: [
        'Full reimbursement of chronic medicines (diabetes, hypertension, cardiac care)',
        'Partnerships with tertiary hospitals for priority cashless admission',
        'Prosthetics and disability mobility equipment distribution',
        'Confidential trauma and grief psychological counseling'
      ],
      eligibleCriteria: [
        'Spouse, dependent children, and parents of martyrs',
        'Submission of doctor prescriptions and hospital treatment estimates',
        'Coordination with ECHS (Ex-Servicemen Contributory Health Scheme) if applicable'
      ],
    ),
    const ServiceProgram(
      id: 'employment',
      title: 'Employment & Skill Development',
      subtitle: 'Self-reliance and dignified livelihoods',
      description:
          'We train and upskill martyr wives and grown children in digital skills, entrepreneurship, handicrafts, and job placement to ensure lifelong independence.',
      imagePath: 'assets/images/donation-3.jpg',
      icon: Icons.business_center,
      benefits: [
        'Vocational training in computer operations, accounting, and tailoring',
        'Seed micro-grants for starting home businesses and local enterprises',
        'Corporate tie-ups for placement and affirmative action recruitment',
        'Resume coaching and interview preparation masterclasses'
      ],
      eligibleCriteria: [
        'Widows and dependents of martyrs between 18 and 45 years',
        'Willingness to complete designated vocational courses',
        'Business plan submission for self-employment grants'
      ],
    ),
    const ServiceProgram(
      id: 'disability',
      title: 'Disability & Mobility Care',
      subtitle: 'Assistive equipment & dignified rehabilitation',
      description:
          'Dedicated support for Divyangjan (specially-abled individuals) and injured defense personnel, distributing high-grade wheelchairs, motorized tricycles, braille kits, hearing aids, and specialized physical therapy.',
      imagePath: 'assets/images/donation-2.jpg',
      icon: Icons.accessible,
      benefits: [
        'Free distribution of customized lightweight wheelchairs and motorized tricycles',
        'Advanced prosthetic limbs and orthotic mobility calipers',
        'Digital hearing aids, smart canes, and braille learning kits',
        'Regular rehabilitation follow-ups and vocational disability empowerment'
      ],
      eligibleCriteria: [
        'Citizens and defense veterans with valid Disability Certificate (UDID card)',
        'Children and seniors with documented physical or sensory impairment',
        'Priority to martyr dependent family members and low-income households'
      ],
    ),
  ];

  // Official Documents & Transparency
  final List<DocumentModel> documents = [
    const DocumentModel(
      id: 'pan',
      title: 'Official Permanent Account Number (PAN)',
      category: 'Legal Identity',
      registrationOrDocNumber: 'AAECS8948K',
      issuingAuthority: 'Income Tax Department, Govt of India',
      description:
          'Permanent Account Number issued to SHAHEED FOUNDATION for financial identity and statutory compliances.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '04 Oct 2022',
    ),
    const DocumentModel(
      id: 'section8',
      title: 'Certificate of Incorporation (Section 8)',
      category: 'Corporate Registration',
      registrationOrDocNumber: 'U85300HR2022NPL101988',
      issuingAuthority: 'Ministry of Corporate Affairs, Govt of India',
      description:
          'Incorporation license under Section 8 of the Companies Act, 2013, dedicated purely to charitable welfare.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '18 Nov 2022',
    ),
    const DocumentModel(
      id: '80g',
      title: 'Section 80G Tax Exemption Approval',
      category: 'Tax Benefit',
      registrationOrDocNumber: 'CIT(EXEMP)/80G/2023-24',
      issuingAuthority: 'Income Tax Department (Exemptions)',
      description:
          'Donors can claim 50% tax deductions on all voluntary donations made to Shaheed Foundation of India.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '01 Apr 2023',
    ),
    const DocumentModel(
      id: '12a',
      title: '12A Non-Profit Registration',
      category: 'Tax Exemption',
      registrationOrDocNumber: '12A/2022-23/REG-9812',
      issuingAuthority: 'Director of Income Tax (Exemption)',
      description:
          'Confers perpetual income tax exemption on the income and corpus received by the non-profit trust.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '10 Jan 2023',
    ),
    const DocumentModel(
      id: 'darpan',
      title: 'NITI Aayog NGO Darpan Registration',
      category: 'Statutory Verification',
      registrationOrDocNumber: 'HR/2022/0329182',
      issuingAuthority: 'NITI Aayog, Government of India',
      description:
          'Unique identification number certifying government recognized voluntary organization status on the NGO-Darpan portal.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '14 Dec 2022',
    ),
    const DocumentModel(
      id: 'csr1',
      title: 'CSR-1 Registration Certificate',
      category: 'Corporate Social Responsibility',
      registrationOrDocNumber: 'CSR00042918',
      issuingAuthority: 'Ministry of Corporate Affairs, Govt of India',
      description:
          'Official authorization allowing companies and corporate bodies to execute CSR welfare partnerships with Shaheed Foundation.',
      assetPath: 'assets/images/sf/PAN CARD.jpeg',
      dateOfIssue: '22 Feb 2023',
    ),
  ];

  // Team
  final List<TeamMember> team = [
    const TeamMember(
      name: 'Col. Rajesh Verma (Retd.)',
      role: 'Patron & Senior Advisor',
      description: 'Veteran with 32 years of dedicated service in Indian Armed Forces. Leading welfare & outreach.',
      imagePath: 'assets/images/team-1.jpg',
    ),
    const TeamMember(
      name: 'Sunita Chauhan',
      role: 'Founder & Managing Trustee',
      description: 'Devoted social worker dedicated to martyr family rehabilitation and empowerment since 2018.',
      imagePath: 'assets/images/team-2.jpg',
    ),
    const TeamMember(
      name: 'Maj. Amit Sharma (Retd.)',
      role: 'Head of Operations & Grants',
      description: 'Ensuring 100% verified and speedy delivery of education and financial assistance to needy families.',
      imagePath: 'assets/images/team-3.jpg',
    ),
  ];

  // Events
  final List<EventModel> events = [
    const EventModel(
      id: 'ev1',
      title: 'Veer Nari Samman & Scholarship Ceremony',
      date: '26 Oct 2026',
      location: 'Civil Lines Community Center, Gurugram',
      description:
          'Annual memorial gathering felicitating 25 Veer Naris (martyr widows) and distributing scholarships to 60 children.',
      imagePath: 'assets/images/event-1.jpg',
      category: 'Memorial',
    ),
    const EventModel(
      id: 'ev2',
      title: 'Free Health & Mobility Checkup Camp',
      date: '15 Nov 2026',
      location: 'Sector 12 A Park, Gurugram',
      description:
          'Specialist cardiac, orthopaedic and eye health camp with free assistive equipment distribution for elderly parents.',
      imagePath: 'assets/images/event-2.jpg',
      category: 'Healthcare',
    ),
    const EventModel(
      id: 'ev3',
      title: 'National Martyrs Tribute & Youth Marathon',
      date: '16 Dec 2026',
      location: 'Leisure Valley Ground, Gurugram',
      description:
          'Vijay Diwas 5km run to promote awareness and honor the heroes who defended the motherland.',
      imagePath: 'assets/images/event-3.jpg',
      category: 'Welfare Drive',
    ),
  ];

  // Gallery
  final List<GalleryItem> gallery = [
    const GalleryItem(
      id: 'g1',
      title: 'Wreath Laying Ceremony',
      imagePath: 'assets/images/gallery-1.jpg',
      tag: 'Memorial',
    ),
    const GalleryItem(
      id: 'g2',
      title: 'School Bag & Uniform Distribution',
      imagePath: 'assets/images/gallery-2.jpg',
      tag: 'Education',
    ),
    const GalleryItem(
      id: 'g3',
      title: 'Medical Aid Distribution',
      imagePath: 'assets/images/gallery-3.jpg',
      tag: 'Health',
    ),
    const GalleryItem(
      id: 'g4',
      title: 'Veer Nari Sewing Center Inauguration',
      imagePath: 'assets/images/gallery-4.jpg',
      tag: 'Employment',
    ),
    const GalleryItem(
      id: 'g5',
      title: 'Ration Kit Relief Distribution',
      imagePath: 'assets/images/gallery-5.jpg',
      tag: 'Relief',
    ),
    const GalleryItem(
      id: 'g6',
      title: 'Youth Volunteer Orientation',
      imagePath: 'assets/images/gallery-6.jpg',
      tag: 'Volunteers',
    ),
  ];

  // Members List (Stateful)
  final List<MemberModel> _members = [
    MemberModel(
      id: '1',
      publicId: 'SFOF-2024-0012',
      fullName: 'Vikramaditya Singh',
      gender: 'Male',
      dob: '1988-08-15',
      relationType: 'S/O',
      relationName: 'Late Subedar Ram Singh',
      mobile: '+919876543210',
      email: 'vikram.singh@sfofindia.org',
      state: 'Haryana',
      district: 'Gurugram',
      address: 'Flat 402, Shanti Vihar, Sector 14, Gurugram',
      pinCode: '122001',
      occupation: 'Defense Welfare Activist',
      qualification: 'Post Graduate (MA History)',
      aadharNumber: '984512345678',
      status: 'Verified',
      registrationDate: DateTime(2024, 1, 15),
      bloodGroup: 'O+',
    ),
    MemberModel(
      id: '2',
      publicId: 'SFOF-2024-0089',
      fullName: 'Pooja Rani',
      gender: 'Female',
      dob: '1992-03-22',
      relationType: 'W/O',
      relationName: 'Late Havildar Manoj Kumar',
      mobile: '+919812345678',
      email: 'pooja.rani@sfofindia.org',
      state: 'Punjab',
      district: 'Patiala',
      address: 'House No. 12B, Model Town, Patiala',
      pinCode: '147001',
      occupation: 'Teacher',
      qualification: 'B.Ed, M.Sc',
      aadharNumber: '453278901234',
      status: 'Verified',
      registrationDate: DateTime(2024, 3, 10),
      bloodGroup: 'B+',
    ),
    MemberModel(
      id: '3',
      publicId: 'SFOF-2024-0145',
      fullName: 'Sunil Dutt Rao',
      gender: 'Male',
      dob: '1982-11-04',
      relationType: 'S/O',
      relationName: 'Late Naib Subedar Krishan Rao',
      mobile: '+919845612390',
      email: 'sunil.rao@sfofindia.org',
      state: 'Rajasthan',
      district: 'Alwar',
      address: 'Village Behror, Tehsil Behror, Alwar',
      pinCode: '301701',
      occupation: 'Civil Engineer',
      qualification: 'B.Tech Civil',
      aadharNumber: '678912344567',
      status: 'Verified',
      registrationDate: DateTime(2024, 5, 20),
      bloodGroup: 'A+',
    ),
  ];

  List<MemberModel> get members => List.unmodifiable(_members);

  // Donations List (Stateful)
  final List<DonationModel> _donations = [
    DonationModel(
      id: 'DON-1001',
      donorName: 'Harpreet Singh',
      donorEmail: 'harpreet.s@sfofindia.org',
      donorPhone: '+919811122233',
      amount: 5000,
      paymentMethod: 'UPI',
      paymentStatus: 'Completed',
      date: DateTime.now().subtract(const Duration(days: 2)),
      receiptNumber: 'SFOF-80G-2026-0042',
      panNumber: 'ABCPS1234K',
      transactionRef: 'UPI/AXIS/409823412',
    ),
    DonationModel(
      id: 'DON-1002',
      donorName: 'Anjali Deshmukh',
      donorEmail: 'anjali.d@sfofindia.org',
      donorPhone: '+919922334455',
      amount: 2000,
      paymentMethod: 'Axis Bank Transfer',
      paymentStatus: 'Completed',
      date: DateTime.now().subtract(const Duration(days: 5)),
      receiptNumber: 'SFOF-80G-2026-0041',
      panNumber: 'BTPPD9876M',
      transactionRef: 'NEFT/AXIS/9823411',
    ),
  ];

  List<DonationModel> get donations => List.unmodifiable(_donations);

  // Verification method
  MemberModel? verifyMember(String query) {
    final clean = query.trim().toUpperCase().replaceAll(' ', '');
    if (clean.isEmpty) return null;

    try {
      return _members.firstWhere(
        (m) =>
            m.publicId.toUpperCase() == clean ||
            m.mobile.replaceAll(RegExp(r'[^0-9]'), '') == clean.replaceAll(RegExp(r'[^0-9]'), '') ||
            m.aadharNumber == clean ||
            m.fullName.toUpperCase().contains(clean),
      );
    } catch (_) {
      return null;
    }
  }

  // Uniqueness validation methods
  bool isMobileRegistered(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return false;
    return _members.any((m) => m.mobile.replaceAll(RegExp(r'[^0-9]'), '') == clean);
  }

  bool isAadharRegistered(String aadhar) {
    final clean = aadhar.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return false;
    return _members.any((m) => m.aadharNumber.replaceAll(RegExp(r'[^0-9]'), '') == clean);
  }

  bool isEmailRegistered(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return false;
    return _members.any((m) => m.email.toLowerCase() == clean);
  }

  // Add Member
  MemberModel registerMember({
    required String fullName,
    required String gender,
    required String dob,
    required String relationType,
    required String relationName,
    required String mobile,
    required String email,
    required String state,
    required String district,
    required String address,
    required String pinCode,
    required String occupation,
    required String qualification,
    required String aadharNumber,
    String? bloodGroup,
  }) {
    final nextId = _members.length + 1;
    final publicId = 'SFOF-${DateTime.now().year}-${nextId.toString().padLeft(4, '0')}';

    final newMember = MemberModel(
      id: nextId.toString(),
      publicId: publicId,
      fullName: fullName,
      gender: gender,
      dob: dob,
      relationType: relationType,
      relationName: relationName,
      mobile: mobile,
      email: email,
      state: state,
      district: district,
      address: address,
      pinCode: pinCode,
      occupation: occupation,
      qualification: qualification,
      aadharNumber: aadharNumber,
      status: 'Verified',
      registrationDate: DateTime.now(),
      bloodGroup: bloodGroup,
    );

    _members.insert(0, newMember);
    notifyListeners();
    return newMember;
  }


  // Verified & Approved Beneficiary Testimonials (Loaded dynamically from MySQL database)
  final List<TestimonialItem> testimonials = [];

  void setTestimonials(List<TestimonialItem> items) {
    testimonials.clear();
    testimonials.addAll(items);
    notifyListeners();
  }

  void addTestimonial(TestimonialItem item) {
    testimonials.insert(0, item);
    notifyListeners();
  }

  // News, Bulletins & Field Stories
  final List<NewsArticle> news = [
    const NewsArticle(
      id: 'n1',
      title: 'Mega Veer Nari Samman: Scholarships Distributed to 60 Martyr Dependents',
      category: 'Memorial Tributes',
      date: '12 Sep 2026',
      readTime: '3 min read',
      summary:
          'Annual memorial gathering held in Gurugram felicitating 25 Veer Naris and conferring merit scholarships to children of fallen heroes.',
      content:
          'In a moving solemn ceremony held at the Civil Lines auditorium, Shaheed Foundation of India conferred honors and financial scholarships to over 60 children of armed forces and paramilitary martyrs.\n\nKey dignitaries, retired defense officers, and civil leaders attended the convention. Cheques covering annual tuition, textbooks, and computer tablets were handed over directly to each student.\n\n"Every martyr\'s child is a child of Bharat," stated Managing Trustee Sunita Chauhan. "Their education and dreams are our national responsibility."',
      imagePath: 'assets/images/event-1.jpg',
      views: 3420,
    ),
    const NewsArticle(
      id: 'n2',
      title: 'Free Mobility Camp: 120 Wheelchairs & Motorized Tricycles Handed Over to Divyangjan',
      category: 'Healthcare Camps',
      date: '28 Aug 2026',
      readTime: '4 min read',
      summary:
          'Comprehensive health screening and mobility aid distribution organized in coordination with specialist doctors and orthotists.',
      content:
          'Over 120 Divyangjan and injured defense veterans received customized mobility equipment at the Sector 12 welfare ground today.\n\nThe drive featured on-the-spot assessments by certified orthotists to ensure wheelchairs and motorized tricycles were custom-fitted to each recipient\'s physical needs. Follow-up maintenance and physical therapy counseling will be provided free of cost over the coming 12 months.',
      imagePath: 'assets/images/event-2.jpg',
      views: 2890,
    ),
    const NewsArticle(
      id: 'n3',
      title: 'Section 80G Tax Savings Guide: How Indian Taxpayers Can Maximize Impact with 50% Exemption',
      category: 'Welfare Bulletins',
      date: '15 Aug 2026',
      readTime: '5 min read',
      summary:
          'Comprehensive breakdown of 80G tax benefits, Form 10BD electronic receipts, and how charitable giving benefits both martyrs\' families and donors.',
      content:
          'Under Section 80G of the Indian Income Tax Act, 1961, all voluntary contributions made to Shaheed Foundation of India qualify for a 50% deduction from taxable income.\n\nFor individuals in the 30% tax bracket, an effective contribution of ₹10,000 saves ₹1,560 in taxes, making the net cost of helping a martyr\'s family only ₹8,440. All receipts are stamped with government Form 10BD compliance for automated pre-fill on the Income Tax e-filing portal.',
      imagePath: 'assets/images/donation-1.jpg',
      views: 4120,
    ),
    const NewsArticle(
      id: 'n4',
      title: 'Vijay Diwas 5K Awareness Run Announced for December 2026',
      category: 'Memorial Tributes',
      date: '02 Aug 2026',
      readTime: '2 min read',
      summary:
          'Annual youth marathon to honor the brave heroes of the 1971 liberation war and mobilize volunteer support for martyrs\' families.',
      content:
          'Registration for the annual Vijay Diwas 5K Marathon is officially open. The marathon invites youth, veterans, corporate volunteers, and citizens from all walks of life to run in tribute of India\'s defense heroes.\n\nAll participant registration contributions will directly fund emergency medical grants for elderly parents of fallen soldiers.',
      imagePath: 'assets/images/event-3.jpg',
      views: 1980,
    ),
  ];

  // Aid Applications (Local Store)
  final List<AidApplicationRecord> _aidApplications = [
    AidApplicationRecord(
      referenceId: 'AID-20260910-4821',
      applicantName: 'Smt. Seema Devi',
      phone: '+919812456789',
      email: 'seema.devi@sfofindia.org',
      martyrName: 'Late Naik Ramesh Kumar',
      relation: 'Wife (Veer Nari)',
      program: "Children's Education Support",
      address: 'VPO Kosli, District Rewari, Haryana',
      details: 'Requesting college tuition fee assistance for son\'s second year B.Sc degree.',
      status: 'Approved & Grant Disbursed',
    ),
    AidApplicationRecord(
      referenceId: 'AID-20260912-7819',
      applicantName: 'Subedar R. K. Yadav (Retd.)',
      phone: '+919876512340',
      email: 'rkyadav@sfofindia.org',
      martyrName: 'Self (War Disabled)',
      relation: 'Disabled Veteran',
      program: 'Disability & Mobility Care',
      address: 'House 144, Sector 7, Gurugram',
      details: 'Motorized wheelchair requisition for daily mobility following lower limb injury.',
      status: 'Under Field Verification',
    ),
  ];

  List<AidApplicationRecord> get aidApplications => List.unmodifiable(_aidApplications);

  // Volunteer Registrations
  final List<Map<String, dynamic>> _volunteerRsvps = [];
  List<Map<String, dynamic>> get volunteerRsvps => List.unmodifiable(_volunteerRsvps);

  void recordVolunteerRsvp({
    required String eventId,
    required String eventTitle,
    required String name,
    required String phone,
    required String city,
  }) {
    _volunteerRsvps.add({
      'eventId': eventId,
      'eventTitle': eventTitle,
      'name': name,
      'phone': phone,
      'city': city,
      'timestamp': DateTime.now(),
    });
    notifyListeners();
  }

  AidApplicationRecord recordAidApplication({
    required String applicantName,
    required String phone,
    required String email,
    required String martyrName,
    required String relation,
    required String program,
    required String address,
    required String details,
    String? referenceId,
  }) {
    final ref = referenceId ??
        'AID-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${1000 + (_aidApplications.length % 9000)}';

    final rec = AidApplicationRecord(
      referenceId: ref,
      applicantName: applicantName,
      phone: phone,
      email: email,
      martyrName: martyrName,
      relation: relation,
      program: program,
      address: address,
      details: details,
      status: 'Registered & Under Review',
    );
    _aidApplications.insert(0, rec);
    notifyListeners();
    return rec;
  }


  // --- Memorial Heroes (Wall of Valor) ---
  final List<MemorialHero> _memorialHeroes = [
    MemorialHero(
      id: 'batra',
      name: 'Captain Vikram Batra',
      rank: 'Captain',
      regiment: '13 Jammu and Kashmir Rifles',
      warOrOperation: 'Operation Vijay (Kargil War 1999)',
      dateOfMartyrdom: '07 July 1999',
      nativePlace: 'Palampur, Himachal Pradesh',
      gallantryAward: 'Param Vir Chakra (PVC)',
      citation:
          'Known by his codename "Sher Shah", Captain Batra led from the front to recapture Point 5140 and Point 4875. Before his supreme sacrifice, his iconic words "Yeh Dil Maange More" inspired the entire Indian armed forces.',
      photoUrl: 'assets/images/team-1.jpg',
      tributesCount: 48920,
    ),
    MemorialHero(
      id: 'sandeep',
      name: 'Major Sandeep Unnikrishnan',
      rank: 'Major',
      regiment: '51 Special Action Group, NSG / 7 Bihar',
      warOrOperation: 'Operation Black Tornado (26/11 Mumbai 2008)',
      dateOfMartyrdom: '28 November 2008',
      nativePlace: 'Kozhikode, Kerala / Bengaluru',
      gallantryAward: 'Ashoka Chakra (AC)',
      citation:
          'Led the commando operation inside the Taj Mahal Palace Hotel to flush out terrorists and rescue 14 hostages. His parting words to his team: "Do not come up, I will handle them."',
      photoUrl: 'assets/images/team-3.jpg',
      tributesCount: 39140,
    ),
    MemorialHero(
      id: 'joginder',
      name: 'Subedar Joginder Singh',
      rank: 'Subedar',
      regiment: '1st Battalion, Sikh Regiment',
      warOrOperation: 'Battle of Tongpen La (1962 War)',
      dateOfMartyrdom: '23 October 1962',
      nativePlace: 'Mahla Kalan, Moga, Punjab',
      gallantryAward: 'Param Vir Chakra (PVC)',
      citation:
          'Single-handedly inspired his platoon against waves of advancing enemy troops. Despite severe thigh wounds, refused evacuation and manned a light machine gun until his last breath.',
      photoUrl: 'assets/images/team-1.jpg',
      tributesCount: 28430,
    ),
    MemorialHero(
      id: 'abdul',
      name: 'Company Quartermaster Havildar Abdul Hamid',
      rank: 'CQMH',
      regiment: '4th Battalion, The Grenadiers',
      warOrOperation: 'Battle of Asal Uttar (1965 War)',
      dateOfMartyrdom: '10 September 1965',
      nativePlace: 'Dhamupur, Ghazipur, Uttar Pradesh',
      gallantryAward: 'Param Vir Chakra (PVC)',
      citation:
          'Mounted on a jeep with a recoilless gun, Havildar Abdul Hamid knocked out 7 enemy Patton tanks in fierce close-range combat before laying down his life.',
      photoUrl: 'assets/images/team-3.jpg',
      tributesCount: 31200,
    ),
    MemorialHero(
      id: 'manoj',
      name: 'Late Havildar Manoj Kumar',
      rank: 'Havildar',
      regiment: '14 Rajput Regiment',
      warOrOperation: 'Operation Rakshak (Kashmir Valley)',
      dateOfMartyrdom: '14 August 2021',
      nativePlace: 'Patiala, Punjab / Rewari',
      gallantryAward: 'Sena Medal (Gallantry)',
      citation:
          'Neutralized two infiltrating terrorists during a cordoned night search operation in dense forested terrain, ensuring the safety of his entire squad.',
      photoUrl: 'assets/images/team-2.jpg',
      tributesCount: 19800,
    ),
  ];

  List<MemorialHero> get memorialHeroes => List.unmodifiable(_memorialHeroes);

  final List<HeroTributeMessage> _tributeMessages = [
    HeroTributeMessage(
      id: 'm1',
      heroId: 'batra',
      heroName: 'Captain Vikram Batra, PVC',
      authorName: 'Rohan Deshmukh',
      city: 'Pune, Maharashtra',
      message: 'Your sacrifice is the reason our tricolor flies high with honor. You will live forever in our hearts. Jai Hind!',
    ),
    HeroTributeMessage(
      id: 'm2',
      heroId: 'sandeep',
      heroName: 'Major Sandeep Unnikrishnan, AC',
      authorName: 'Ananya Nair',
      city: 'Bengaluru, Karnataka',
      message: 'A true hero whose courage shielded Mumbai. Gratitude and salutes to his noble parents.',
    ),
  ];

  List<HeroTributeMessage> get tributeMessages => List.unmodifiable(_tributeMessages);

  void incrementHeroDiyaTribute(String heroId) {
    final hero = _memorialHeroes.firstWhere((h) => h.id == heroId);
    hero.tributesCount += 1;
    notifyListeners();
  }

  void addHeroTribute({
    required String heroId,
    required String heroName,
    required String authorName,
    required String city,
    required String message,
  }) {
    final tribute = HeroTributeMessage(
      id: 'tr-${DateTime.now().millisecondsSinceEpoch}',
      heroId: heroId,
      heroName: heroName,
      authorName: authorName,
      city: city,
      message: message,
    );
    _tributeMessages.insert(0, tribute);
    notifyListeners();
  }

  // --- Defense Welfare & Govt Schemes Directory ---
  final List<WelfareScheme> welfareSchemes = [
    const WelfareScheme(
      id: 'ksb_edu',
      title: 'KSB Education Grant for Children of Martyrs & ESM',
      hindiTitle: 'केंद्रीय सैनिक बोर्ड (KSB) - शहीद बच्चों हेतु शिक्षा अनुदान',
      issuingBody: 'Kendriya Sainik Board, Ministry of Defence',
      category: 'KSB Central',
      eligibility: 'Widows and dependent children of defense martyrs up to graduation/professional degree.',
      financialBenefits: '₹1,000 per month per child (paid annually as ₹12,000) for school up to 2 children.',
      nonFinancialBenefits: [
        'Eligible for PMSS (Prime Minister Scholarship Scheme) up to ₹3,000/month for engineering, medical & MBA',
        'Direct transfer to student bank account without intermediaries',
      ],
      requiredDocuments: [
        'Discharge Book / Battle Casualty Certificate',
        'Bonafide student certificate from recognized school/college',
        'Bank passbook photocopy showing IFS code',
        'Part II Order of family details',
      ],
      applicationProcess: 'Apply online through ksb.gov.in portal. Verification by Zila Sainik Welfare Officer (ZSWO).',
      helplineContact: '1800-11-2022',
      officialPortalUrl: 'https://ksb.gov.in',
    ),
    const WelfareScheme(
      id: 'haryana_exgratia',
      title: 'Haryana State Martyr Ex-Gratia & Govt Job Scheme',
      hindiTitle: 'हरियाणा सरकार - शहीद परिवार ₹50 लाख अनुग्रह राशि एवं सरकारी नौकरी',
      issuingBody: 'Rajya Sainik Board, Govt of Haryana',
      category: 'State Ex-Gratia',
      eligibility: 'Next of kin (Veer Nari / parents) of armed forces personnel domicile of Haryana martyred in war/CI operations.',
      financialBenefits: '₹50 Lakhs lumpsum compensation directly transferred to martyr widow/parents.',
      nonFinancialBenefits: [
        'Direct Government employment on compassionate grounds to one eligible family dependent (Group C or D)',
        'Free bus travel pass across Haryana Roadways for Veer Nari and minor children',
      ],
      requiredDocuments: [
        'Battle Casualty certificate from Service Headquarters',
        'Haryana Domicile Certificate',
        'Legal Heir Certificate / NOC from other family members',
        'Educational certificates for compassionate job requisition',
      ],
      applicationProcess: 'Submit via local District Zila Sainik Board (ZSB). Endorsed by District Magistrate.',
      helplineContact: '0172-2703816',
      officialPortalUrl: 'https://sainikwelfare.haryana.gov.in',
    ),
    const WelfareScheme(
      id: 'echs_health',
      title: 'ECHS (Ex-Servicemen Contributory Health Scheme) Comprehensive Care',
      hindiTitle: 'ECHS - शहीद परिवारों एवं पूर्व सैनिकों हेतु 100% निःशुल्क कैशलेस स्वास्थ्य सेवा',
      issuingBody: 'Department of Ex-Servicemen Welfare, Ministry of Defence',
      category: 'ECHS Healthcare',
      eligibility: 'Veer Naris, minor dependent children, and dependent parents of deceased armed forces personnel.',
      financialBenefits: '100% Cashless hospitalization, cardiac surgeries, cancer therapy, and specialized treatments.',
      nonFinancialBenefits: [
        'Free supply of life-saving and chronic medicines',
        'Pan-India network of empaneled private multi-specialty hospitals',
        'No ceiling on emergency hospital admission costs',
      ],
      requiredDocuments: [
        'ECHS Smart Card / Temporary Slip',
        'Service Pension Payment Order (PPO)',
        'Identity & Aadhar Cards of family members',
      ],
      applicationProcess: 'Enrollment through nearest ECHS Polyclinic or Station Headquarters.',
      helplineContact: '1800-114-115',
      officialPortalUrl: 'https://echs.gov.in',
    ),
    const WelfareScheme(
      id: 'rail_air_quota',
      title: 'Concessional Travel & Central Defense Quota Admissions',
      hindiTitle: 'भारतीय रेलवे 75% रियायत एवं केंद्रीय विद्यालय/मेडिकल रक्षा कोटा',
      issuingBody: 'Ministry of Railways & Ministry of Education',
      category: 'Concessions & Quotas',
      eligibility: 'Veer Naris (widows of defense personnel killed in action) and their dependent children.',
      financialBenefits: '75% concession on Indian Railways 2nd Class and Sleeper fares; 50% concession on Air India domestic flights.',
      nonFinancialBenefits: [
        'Priority 1 reservation quota for children in Kendriya Vidyalayas and Sainik Schools',
        'Special Ministry of Defence quota seats in MBBS and engineering colleges',
      ],
      requiredDocuments: [
        'Railway Concession Certificate issued by Zila Sainik Board',
        'Battle Casualty Identity Card issued by AG Branch',
      ],
      applicationProcess: 'Obtain photo ID certificate from District Sainik Board and produce at reservation counter.',
      helplineContact: '139 (Railways)',
      officialPortalUrl: 'https://indianrailways.gov.in',
    ),
  ];

  // --- Community Blood Donor Network ---
  final List<RegisteredBloodDonor> _bloodDonors = [
    RegisteredBloodDonor(
      id: 'bd1',
      fullName: 'Vikramaditya Singh',
      bloodGroup: 'O+',
      phone: '+919876543210',
      city: 'Gurugram',
      state: 'Haryana',
      lastDonationDate: '15 June 2026',
    ),
    RegisteredBloodDonor(
      id: 'bd2',
      fullName: 'Amitabh Sen',
      bloodGroup: 'B+',
      phone: '+919812345678',
      city: 'Patiala',
      state: 'Punjab',
      lastDonationDate: '10 July 2026',
    ),
    RegisteredBloodDonor(
      id: 'bd3',
      fullName: 'Rajesh Kaushik',
      bloodGroup: 'A+',
      phone: '+919845123456',
      city: 'Delhi NCR',
      state: 'Delhi',
      lastDonationDate: '01 August 2026',
    ),
    RegisteredBloodDonor(
      id: 'bd4',
      fullName: 'Sunil Kumar',
      bloodGroup: 'AB+',
      phone: '+919899123456',
      city: 'Rewari',
      state: 'Haryana',
      lastDonationDate: '20 May 2026',
    ),
  ];

  List<RegisteredBloodDonor> get bloodDonors => List.unmodifiable(_bloodDonors);

  RegisteredBloodDonor registerBloodDonor({
    required String fullName,
    required String bloodGroup,
    required String phone,
    required String city,
    required String state,
    String? lastDonationDate,
  }) {
    final donor = RegisteredBloodDonor(
      id: 'donor-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      bloodGroup: bloodGroup,
      phone: phone,
      city: city,
      state: state,
      lastDonationDate: lastDonationDate ?? 'First-Time Hero Donor',
    );
    _bloodDonors.insert(0, donor);
    notifyListeners();
    return donor;
  }

  // Add Donation
  DonationModel recordDonation({
    required String donorName,
    required String donorEmail,
    required String donorPhone,
    required double amount,
    required String paymentMethod,
    String? panNumber,
    String? transactionRef,
    String? receiptNumber,
  }) {
    final count = _donations.length + 1;
    final receiptNo = receiptNumber ?? 'SFOF-80G-${DateTime.now().year}-${count.toString().padLeft(4, '0')}';
    final donId = 'DON-${1000 + count}';

    final donation = DonationModel(
      id: donId,
      donorName: donorName,
      donorEmail: donorEmail,
      donorPhone: donorPhone,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentStatus: 'Completed',
      date: DateTime.now(),
      panNumber: panNumber,
      receiptNumber: receiptNo,
      transactionRef: transactionRef ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );

    _donations.insert(0, donation);
    notifyListeners();
    return donation;
  }
}
