import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_repository.dart';
import '../../services/api_service.dart';
import '../donation/donation_screen.dart';

class ImpactStoriesScreen extends StatefulWidget {
  const ImpactStoriesScreen({super.key});

  @override
  State<ImpactStoriesScreen> createState() => _ImpactStoriesScreenState();
}

class _ImpactStoriesScreenState extends State<ImpactStoriesScreen> {
  List<TestimonialItem> _testimonials = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    setState(() => _isLoading = true);
    final repo = AppRepository();
    _testimonials = List.from(repo.testimonials);

    try {
      final res = await ApiService().getTestimonials();
      if (res.isSuccess && res.data is List && mounted) {
        final List list = res.data as List;
        _testimonials = list.map((m) => TestimonialItem.fromJson(Map<String, dynamic>.from(m))).toList();
        repo.setTestimonials(_testimonials);
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _openReviewModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final progCtrl = TextEditingController();
    final quoteCtrl = TextEditingController();
    int rating = 5;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.rate_review, color: AppTheme.primaryGoldDark, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Your Story / Review',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                            ),
                            Text(
                              'Subject to review & approval by Foundation Admin',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFFF57F17), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To preserve authenticity, citizen & beneficiary stories only appear publicly after being verified and approved by the admin.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF5D4037), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: roleCtrl,
                          decoration: InputDecoration(
                            labelText: 'Your Role / Relation',
                            hintText: 'e.g. Beneficiary, Veer Nari',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: locCtrl,
                          decoration: InputDecoration(
                            labelText: 'City & State',
                            hintText: 'e.g. Rohtak, Haryana',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: progCtrl,
                    decoration: InputDecoration(
                      labelText: 'Program or Cause Supported',
                      hintText: 'e.g. Education Aid, Elderly Healthcare',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ...List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFFFB300),
                            size: 26,
                          ),
                          onPressed: () => setModalState(() => rating = index + 1),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quoteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Your Story / Review Quote *',
                      hintText: 'Describe how the foundation supported you or how you participated...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final quote = quoteCtrl.text.trim();
                              if (name.isEmpty || quote.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your name and story.')),
                                );
                                return;
                              }
                              setModalState(() => isSubmitting = true);
                              final res = await ApiService().submitTestimonial(
                                data: {
                                  'name': name,
                                  'relation': roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : 'Beneficiary',
                                  'location': locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : 'India',
                                  'program': progCtrl.text.trim().isNotEmpty ? progCtrl.text.trim() : 'Welfare & Relief',
                                  'quote': quote,
                                  'rating': rating,
                                  'impact_badge': 'Verified Beneficiary',
                                },
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.message ?? 'Review submitted! It will appear once approved by admin.'),
                                    backgroundColor: AppTheme.secondaryNavy,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      icon: isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(isSubmitting ? 'Submitting...' : 'Submit for Admin Approval'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.secondaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Impact Stories & Testimonials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'Submit Story',
            onPressed: () => _openReviewModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTestimonials,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTestimonials,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.navyDark, AppTheme.secondaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.military_tech_rounded, color: AppTheme.primaryGold, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Honoring Our Heroes',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Voices of Courage & Gratitude',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Behind every statistic is a real family whose courage inspires our nation. Read firsthand testimonials from Veer Naris, student scholars, and assisted seniors.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // 4-Block Quick Metric Grid
                  Row(
                    children: [
                      _buildMetricBox('1,200+', 'Families\nSupported'),
                      const SizedBox(width: 8),
                      _buildMetricBox('3,500+', 'Students\nEducated'),
                      const SizedBox(width: 8),
                      _buildMetricBox('850+', 'Mobility\nAids Given'),
                      const SizedBox(width: 8),
                      _buildMetricBox('100%', '80G Tax\nCompliant'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Firsthand Beneficiary Testimonials',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
                TextButton.icon(
                  onPressed: () => _openReviewModal(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Share Story'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGoldDark),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_testimonials.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppTheme.primaryGoldDark, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Strict Verification & Moderation Active',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryNavy),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'All beneficiary stories and reviews submitted by citizens undergo manual administrative verification before appearing here.\n\nHave you or your family received support or participated in our welfare drives?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openReviewModal(context),
                      icon: const Icon(Icons.rate_review, size: 16),
                      label: const Text('Submit Your Story / Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.secondaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._testimonials.map((t) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Avatar, Name, Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.secondaryNavy.withAlpha(20),
                              child: ClipOval(
                                child: Image.asset(
                                  t.imagePath,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppTheme.secondaryNavy, size: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          t.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.secondaryNavy,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, size: 16, color: Color(0xFF137333)),
                                    ],
                                  ),
                                  Text(
                                    t.relation,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGoldDark),
                                  ),
                                  Text(
                                    t.location,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F4EA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.impactBadge,
                                style: const TextStyle(color: Color(0xFF137333), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Program Badge & Rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Assisted via: ${t.program}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                t.rating.clamp(1, 5),
                                (i) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Quote with quotation icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.format_quote_rounded, color: AppTheme.primaryGold, size: 24),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t.quote,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Share & Support
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                final shareText =
                                    '"${t.quote}" — ${t.name} (${t.relation})\n\nStand with the families of our fallen heroes: ${AppConstants.websiteUrl}';
                                Clipboard.setData(ClipboardData(text: shareText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Testimonial copied to clipboard! Share it with pride.')),
                                );
                              },
                              icon: const Icon(Icons.share, size: 14, color: AppTheme.secondaryNavy),
                              label: const Text('Share Quote', style: TextStyle(fontSize: 12, color: AppTheme.secondaryNavy)),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DonationScreen()),
                                );
                              },
                              icon: const Icon(Icons.favorite, size: 14),
                              label: const Text('Support Families', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.secondaryNavy,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 9, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
