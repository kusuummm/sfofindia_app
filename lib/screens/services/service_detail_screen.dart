import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../about/about_screen.dart';
import '../contact/contact_screen.dart';
import '../documents/documents_screen.dart';
import '../donation/donation_screen.dart';
import '../gallery/gallery_screen.dart';
import '../member/member_apply_screen.dart';
import '../team/our_team_screen.dart';

enum ServiceType { financial, education, medical, employment }

class ServiceDetailScreen extends StatelessWidget {
  final ServiceType serviceType;
  final Function(int)? onNavigateTab;

  const ServiceDetailScreen({
    super.key,
    required this.serviceType,
    this.onNavigateTab,
  });

  Map<String, dynamic> _getData() {
    switch (serviceType) {
      case ServiceType.financial:
        return {
          'title': 'Financial Assistance',
          'breadcrumb': 'Financial Assistance',
          'tag': 'FAMILY FINANCIAL SUPPORT',
          'heroTitle': 'Standing Strong with the Families of Our Martyrs',
          'heroSub':
              'Shaheed Foundation of India provides continuous financial and household support to the families of our brave martyrs — ensuring stability, dignity, and security in their daily lives.',
          'image': 'assets/images/programs/financial_aid.jpg',
          'fallbackIcon': Icons.currency_rupee,
          'features': [
            {
              'icon': Icons.volunteer_activism,
              'title': 'Direct Financial Assistance',
              'desc': 'Direct financial help to support families after the irreplaceable loss of their loved one.',
            },
            {
              'icon': Icons.calendar_month,
              'title': 'Monthly Family Support',
              'desc': 'Fixed monthly sustenance to manage household utilities and daily living expenses with confidence.',
            },
            {
              'icon': Icons.emergency,
              'title': 'Emergency Financial Aid',
              'desc': 'Immediate fast-track assistance during acute medical crises and unexpected household emergencies.',
            },
            {
              'icon': Icons.shopping_basket,
              'title': 'Household & Ration Kits',
              'desc': 'Monthly ration kits (wheat, rice, pulses, cooking oil) and essential supplies ensuring no family goes hungry.',
            },
          ],
          'details': [
            {
              'title': 'One-Time & Recurring Financial Grants',
              'points': [
                'Immediate ex-gratia financial relief upon martyrdom.',
                'Monthly subsistence allowance for widows and aged parents.',
                'Assistance in unlocking government ex-gratia pensions and benefits.',
              ],
            },
            {
              'title': 'Monthly Household Living Support',
              'points': [
                'Fixed monthly monetary aid deposited directly to bank accounts.',
                'Assistance for electricity, clean water, rent, and sanitation bills.',
                'Continuous social worker check-ins for long-term well-being.',
              ],
            },
            {
              'title': 'Emergency Relief Fund',
              'points': [
                '24/7 emergency response hotline for urgent assistance.',
                'No red tape: rapid disbursals within 24–48 hours for urgent situations.',
                'Support for unexpected home repairs and seasonal winter aid.',
              ],
            },
          ],
          'impactStats': [
            {'value': '40+', 'label': 'Families Supported'},
            {'value': '500+', 'label': 'Monthly Ration Kits'},
            {'value': '100+', 'label': 'Emergency Cases Handled'},
          ],
        };

      case ServiceType.education:
        return {
          'title': 'Children’s Education Support',
          'breadcrumb': 'Education Support',
          'tag': 'CHILDREN\'S EDUCATION',
          'heroTitle': 'Empowering the Children of Our Brave Martyrs',
          'heroSub':
              'Shaheed Foundation ensures that every child of a martyr receives uninterrupted education, modern guidance, and full resources from nursery through higher graduation.',
          'image': 'assets/images/programs/child_education.jpg',
          'fallbackIcon': Icons.school,
          'features': [
            {
              'icon': Icons.school_outlined,
              'title': 'School & College Fees',
              'desc': 'Full or partial tuition fee coverage for schools, colleges, and university courses.',
            },
            {
              'icon': Icons.menu_book,
              'title': 'Books, Uniforms & Kits',
              'desc': 'Textbooks, stationery, school bags, shoes, and uniforms distributed at start of every academic year.',
            },
            {
              'icon': Icons.military_tech,
              'title': 'Scholarships & Tuition Help',
              'desc': 'Merit-based scholarships and special evening tuition classes to ensure academic excellence.',
            },
            {
              'icon': Icons.psychology,
              'title': 'Competitive Exam Preparation',
              'desc': 'Professional coaching for UPSC, NDA, CDS, NEET, JEE, SSC, and Banking career exams.',
            },
          ],
          'details': [
            {
              'title': 'Uninterrupted Academic Sponsorship',
              'points': [
                'Full sponsorship of annual school tuition and exam fees.',
                'Coverage for higher university degrees (Engineering, Medical, Law, Commerce).',
                'Zero-fee assistance directly paid to registered educational institutions.',
              ],
            },
            {
              'title': 'Complete Educational Toolkits',
              'points': [
                'Free annual package: textbooks, notebooks, stationery, geometry boxes.',
                'Seasonal school uniforms, blazer, shoes, and raincoats.',
                'Laptop / digital tablet assistance for senior students.',
              ],
            },
            {
              'title': 'Mentorship & Defense Prep Wing',
              'points': [
                'Special coaching for children wishing to follow their parents into the Armed Forces.',
                'Career counseling sessions by retired military officers and civil servants.',
                'Regular parent-teacher coordination by foundation volunteers.',
              ],
            },
          ],
          'quote':
              '“After my father’s sacrifice, I feared my studies would stop. Shaheed Foundation helped with fees, books, and coaching. Today I am preparing for NDA confidently.” — Aarav, Class 12',
          'impactStats': [
            {'value': '120+', 'label': 'Children Educated'},
            {'value': '35+', 'label': 'Competitive Aspirants'},
            {'value': '100%', 'label': 'Tuition Assistance'},
          ],
        };

      case ServiceType.medical:
        return {
          'title': 'Medical & Health Care Support',
          'breadcrumb': 'Medical Support',
          'tag': 'HEALTHCARE & REHABILITATION',
          'heroTitle': 'Supporting Martyrs\' Families with Healthcare & Dignity',
          'heroSub':
              'Providing essential medical treatments, surgeries, monthly medicines, assistive mobility devices, and mental health counseling to martyrs’ families.',
          'image': 'assets/images/programs/disability_support.jpg',
          'fallbackIcon': Icons.medical_services,
          'features': [
            {
              'icon': Icons.local_hospital,
              'title': 'Surgeries & Critical Care',
              'desc': 'Coverage for major operations, hospital stays, and specialized medical procedures.',
            },
            {
              'icon': Icons.medication,
              'title': 'Monthly Prescription Support',
              'desc': 'Lifelong medicine supplies and routine medical checkups for elderly parents and widows.',
            },
            {
              'icon': Icons.accessible_forward,
              'title': 'Mobility & Assistive Devices',
              'desc': 'Distribution of motorized wheelchairs, prosthetic limbs, crutches, and hearing aids.',
            },
            {
              'icon': Icons.favorite_border,
              'title': 'Mental Health & Trauma Care',
              'desc': 'Compassionate psychotherapy, grief counseling, and trauma recovery sessions.',
            },
          ],
          'details': [
            {
              'title': 'Comprehensive Medical Coverage',
              'points': [
                'Direct hospital billing settlements for emergency treatments and surgeries.',
                'Free diagnostic lab tests (blood work, MRI, CT scans, ultrasounds).',
                'Coordination with leading super-specialty hospitals across India.',
              ],
            },
            {
              'title': 'Assistive Devices for Disabled Beneficiaries',
              'points': [
                'Custom motorized wheelchairs and tricycles for disabled dependents.',
                'Advanced bionic prosthetics for wounded personnel and family members.',
                'Digital hearing aids, vision aids, and specialized orthotic supports.',
              ],
            },
            {
              'title': 'Psychological Counseling & Healing',
              'points': [
                'One-on-one sessions with licensed trauma psychologists.',
                'Support circles and community retreats for Veer Naris.',
                'Child psychology support to overcome grief and bereavement anxiety.',
              ],
            },
          ],
          'impactStats': [
            {'value': '250+', 'label': 'Patients Treated'},
            {'value': '80+', 'label': 'Mobility Aids Gifted'},
            {'value': '24/7', 'label': 'Emergency Aid Desk'},
          ],
        };

      case ServiceType.employment:
        return {
          'title': 'Employment & Skill Development',
          'breadcrumb': 'Employment & Skills',
          'tag': 'LIVELIHOOD & EMPOWERMENT',
          'heroTitle': 'Empowering Families with Marketable Skills & Careers',
          'heroSub':
              'We provide vocational training, career placements, and micro-grants for self-employment so that martyrs\' families can lead self-reliant, honorable lives.',
          'image': 'assets/images/programs/empowerment.jpg',
          'fallbackIcon': Icons.work_outline,
          'features': [
            {
              'icon': Icons.business_center,
              'title': 'Job Placement Support',
              'desc': 'Resume development, interview readiness, and direct liaison with private & public corporate employers.',
            },
            {
              'icon': Icons.computer,
              'title': 'IT & Vocational Training',
              'desc': 'Computer literacy, accounting, tailoring, handicrafts, and modern industry-ready certifications.',
            },
            {
              'icon': Icons.storefront,
              'title': 'Self-Employment Grants',
              'desc': 'Seed capital and equipment funding to set up retail shops, tailoring centers, or micro-businesses.',
            },
            {
              'icon': Icons.lightbulb,
              'title': 'Entrepreneurship Mentoring',
              'desc': 'One-on-one business planning, legal compliance support, and continuous financial advice.',
            },
          ],
          'details': [
            {
              'title': 'Direct Career Placement Services',
              'points': [
                'Resume writing workshops and mock interviews with HR leaders.',
                'Corporate placement drives prioritizing martyrs’ dependents.',
                'Government job notification alerts and coaching.',
              ],
            },
            {
              'title': 'Vocational Skill Academies',
              'points': [
                'Sewing & fashion design programs with free sewing machine grants.',
                'Basic computer skills: MS Office, Tally Prime, Graphic Design, Web basics.',
                'Handmade craft production with direct marketplace linkages.',
              ],
            },
            {
              'title': 'Micro-Enterprise Seed Grants',
              'points': [
                'Initial grant of up to ₹50,000 for shop setup or trade equipment.',
                'Zero-interest revolving support fund for women entrepreneurs.',
                'Mentorship on bookkeeping, marketing, and inventory management.',
              ],
            },
          ],
          'impactStats': [
            {'value': '65+', 'label': 'Jobs Secured'},
            {'value': '150+', 'label': 'Women Trained'},
            {'value': '30+', 'label': 'Micro-Startups Funded'},
          ],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
            Expanded(
              child: Text(
                data['title'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Desktop Sub-Navbar Chips
          if (Responsive.isDesktop(context)) _buildDesktopNavbar(context),

          // 2. Breadcrumb Banner
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
                  data['title'],
                  textAlign: TextAlign.center,
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
                        if (onNavigateTab != null) {
                          onNavigateTab!(0);
                        }
                        Navigator.popUntil(context, (route) => route.isFirst);
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
                    const Text(' / ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        child: Text(
                          'Services',
                          style: TextStyle(
                            color: AppTheme.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' /  ${data['breadcrumb']}',
                      style: const TextStyle(
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
                // Tag & Title
                Row(
                  children: [
                    Container(width: 24, height: 3, color: AppTheme.primaryGold),
                    const SizedBox(width: 8),
                    Text(
                      data['tag'],
                      style: const TextStyle(
                        color: AppTheme.primaryGoldDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['heroTitle'],
                  style: const TextStyle(
                    color: AppTheme.secondaryNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['heroSub'],
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Top Two Action Buttons (Apply Aid & Donate)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                        onPressed: () => _showAidApplicationDialog(context, data['title']),
                        icon: const Icon(Icons.assignment, size: 16),
                        label: const Text(
                          'Apply For Support',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: AppTheme.secondaryNavy,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                        onPressed: () {
                          if (onNavigateTab != null) {
                            onNavigateTab!(2);
                            Navigator.pop(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DonationScreen()),
                            );
                          }
                        },
                        icon: const Icon(Icons.favorite, size: 16),
                        label: const Text(
                          'Donate Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4 Summary Feature Cards Grid
                const Text(
                  'Key Program Highlights',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 650 ? 4 : 2;
                    final features = data['features'] as List<dynamic>;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 175,
                      ),
                      itemCount: features.length,
                      itemBuilder: (context, idx) {
                        final f = features[idx] as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryNavy.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(f['icon'] as IconData, color: AppTheme.secondaryNavy, size: 22),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                f['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: AppTheme.secondaryNavy,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  f['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    height: 1.3,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Detailed Program Sections (Bullet lists)
                const Text(
                  'Scope of Support & Benefits',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ...((data['details'] as List<dynamic>).map((d) {
                  final section = d as Map<String, dynamic>;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppTheme.primaryGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                section['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.secondaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...((section['points'] as List<dynamic>).map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4, right: 8),
                                    child: Icon(Icons.fiber_manual_record, size: 8, color: AppTheme.secondaryNavy),
                                  ),
                                  Expanded(
                                    child: Text(
                                      p as String,
                                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.35),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                      ],
                    ),
                  );
                })),

                // Quote / Success story if exists
                if (data['quote'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGold.withAlpha(120)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, color: AppTheme.primaryGoldDark, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['quote'] as String,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12.5,
                              color: AppTheme.secondaryNavy,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Impact Metrics Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.secondaryNavy, Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Program Impact & Reach',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: (data['impactStats'] as List<dynamic>).map((stat) {
                          final s = stat as Map<String, dynamic>;
                          return Column(
                            children: [
                              Text(
                                s['value'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s['label'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bottom CTA Apply
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.support_agent, size: 36, color: AppTheme.secondaryNavy),
                      const SizedBox(height: 8),
                      const Text(
                        'Are You or Someone You Know in Need?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Submit an aid request directly or connect with our national support team.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () => _showAidApplicationDialog(context, data['title']),
                        child: const Text('Submit Aid Application', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAidApplicationDialog(BuildContext context, String programTitle) {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final martyrCtrl = TextEditingController();
    final reqCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.assignment_ind, color: AppTheme.secondaryNavy, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Apply: $programTitle',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please share the beneficiary details below. Our field coordinator will reach out within 24 hours.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Applicant / Guardian Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: martyrCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Shaheed / Martyr Name & Unit',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reqCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Describe Assistance Required *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || mobileCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide your name and contact mobile number')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF16A34A),
                    content: Text('Application submitted successfully for ${nameCtrl.text.trim()}! We will contact you.'),
                  ),
                );
              },
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
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
            if (onNavigateTab != null) {
              onNavigateTab!(0);
            }
            Navigator.popUntil(context, (route) => route.isFirst);
          }),
          _navChip('About', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
          _navChip('Our Team', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OurTeamScreen()));
          }),
          _navChip('Services', isActive: true, onTap: () {
            Navigator.pop(context);
          }),
          _navChip('Donation', onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(2);
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
