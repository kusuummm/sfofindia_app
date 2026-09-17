import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/app_repository.dart';
import '../donation/donation_screen.dart';
import '../contact/contact_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
            const Text('About Us'),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Page Header Banner (Breadcrumb style like website)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppTheme.secondaryNavy,
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryGold, width: 3),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'About Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Home',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      '  /  About Us',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tag & Main Heading
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 3,
                      color: AppTheme.primaryGold,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ABOUT SHAHEED FOUNDATION OF INDIA',
                        style: TextStyle(
                          color: AppTheme.primaryGoldDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Standing With Those Who Gave Everything',
                  style: TextStyle(
                    color: AppTheme.secondaryNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Shaheed Foundation of India is a non-profit organization dedicated to supporting the families of brave martyrs who sacrificed their lives for the nation. Our mission is to ensure that no martyr’s family ever feels alone, forgotten, or helpless.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Image Section
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    AppConstants.aboutImage,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 180,
                      color: AppTheme.secondaryNavy,
                      child: const Center(
                        child: Icon(Icons.people, color: Colors.white30, size: 50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // What We Do Checklist
                const Text(
                  'What We Do',
                  style: TextStyle(
                    color: AppTheme.secondaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCheckItem('Financial assistance for martyrs’ families'),
                _buildCheckItem('Education and healthcare support'),
                _buildCheckItem('Employment and skill development programs'),
                _buildCheckItem('Emergency relief and crisis support'),

                const SizedBox(height: 14),

                // Quote Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(color: AppTheme.primaryGold, width: 4),
                    ),
                  ),
                  child: const Text(
                    '“A nation that honors its martyrs must stand with their families.” 🇮🇳',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Gold Contribution Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your contribution helps us provide dignity, care, and hope to the families of our martyrs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DonationScreen()),
                          );
                        },
                        child: const Text(
                          'Donate Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Banner Section (Honoring Sacrifice...)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Shaheed Foundation of India',
                        style: TextStyle(
                          color: AppTheme.primaryGoldDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Honoring Sacrifice. Supporting Families. Building Hope.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.secondaryNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Shaheed Foundation of India stands beside the families of our brave martyrs, ensuring dignity, care, education, medical support, and long-term security. Your support helps us fulfill the nation’s responsibility towards those who gave everything for our freedom.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DonationScreen()),
                                );
                              },
                              child: const Text(
                                'Donate Now',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryNavy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ContactScreen()),
                                );
                              },
                              child: const Text(
                                'Join as Volunteer',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2x2 Alternating Statistics Grid
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 3,
                      color: AppTheme.primaryGold,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'WHY SUPPORT SHAHEED FAMILIES',
                        style: TextStyle(
                          color: AppTheme.primaryGoldDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Because Their Sacrifice Deserves Our Support',
                  style: TextStyle(
                    color: AppTheme.secondaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'While we sleep safely in our homes, a soldier stands guard at the borders of our nation. When a family loses a son, husband, or father in the service of the country, it becomes our collective responsibility to stand by them with compassion, respect, and support.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // The 2x2 Grid matching website features
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final width = gridConstraints.maxWidth;
                    final ratio = width < 360 ? 0.85 : (width < 500 ? 1.05 : 1.25);
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: ratio,
                      children: [
                        _statBlock('40', 'Martyrs’ Families\nSupported', Icons.groups_rounded, isGold: true),
                        _statBlock('120', 'Martyrs’ Children\nEducated', Icons.school_rounded, isGold: false),
                        _statBlock('85', 'Families Given\nFinancial Support', Icons.currency_rupee_rounded, isGold: false),
                        _statBlock('300', 'Relief & Welfare\nInterventions', Icons.volunteer_activism_rounded, isGold: true),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Leadership Team
                const Text(
                  'Our Leadership & Advisory Board',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dedicated veterans and social leaders guiding our mission',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),

                ...repo.team.map((t) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              t.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 60,
                                height: 60,
                                color: AppTheme.secondaryNavy.withAlpha(20),
                                child: const Icon(Icons.person, color: AppTheme.secondaryNavy),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  t.role,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.primaryGoldDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  t.description,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primaryGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String count, String label, IconData icon, {required bool isGold}) {
    final bgColor = isGold ? AppTheme.primaryGold : AppTheme.secondaryNavy;
    final textColor = isGold ? AppTheme.textDark : Colors.white;
    final iconColor = isGold ? AppTheme.secondaryNavy : AppTheme.primaryGold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
