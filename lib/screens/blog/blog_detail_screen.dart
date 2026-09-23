import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const BlogDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final title = article['title']?.toString() ?? 'Official Announcement';
    final category = article['category']?.toString() ?? 'Press Release';
    final author = article['author']?.toString() ?? 'Shaheed Foundation Bureau';
    final content = article['content']?.toString() ?? (article['summary']?.toString() ?? '');
    final dateStr = article['created_at']?.toString() ?? '';
    String displayDate = 'Official Dispatch';
    if (dateStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateStr);
        displayDate = DateFormat('MMMM dd, yyyy').format(parsed);
      } catch (_) {
        displayDate = dateStr;
      }
    }
    final image = article['image']?.toString() ?? article['featured_image']?.toString() ?? 'assets/images/carousel-1.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Article Details'),
        backgroundColor: AppTheme.secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share Article',
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing: $title'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Image Banner
            Stack(
              children: [
                image.startsWith('assets/')
                    ? Image.asset(
                        image,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _bannerPlaceholder(),
                      )
                    : Image.network(
                        image.startsWith('http') ? image : '${ApiService().baseUrl}/$image',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _bannerPlaceholder(),
                      ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withAlpha(220),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metadata Author & Date Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.secondaryNavy,
                          child: const Icon(Icons.shield, color: AppTheme.primaryGold, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                displayDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Official Post',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Indian National Tricolor Ribbon
                  Row(
                    children: [
                      Expanded(child: Container(height: 3, color: const Color(0xFFFF9933))),
                      Expanded(child: Container(height: 3, color: const Color(0xFFE2E8F0))),
                      Expanded(child: Container(height: 3, color: const Color(0xFF138808))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Paragraphs of Article Content
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF334155),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Official Foundation Footer Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.verified, color: AppTheme.wreathGreen, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Shaheed Foundation of India',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Section 8 Non-Profit Organization (Reg. U85300HR2022NPL101988) dedicated to the welfare of martyrs\' families and veterans.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: const [
                            Text('🌐 sfofindia.com', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            Text('📞 +91 96156 41564', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      height: 220,
      color: AppTheme.secondaryNavy,
      child: const Center(
        child: Icon(Icons.newspaper, size: 56, color: Colors.white30),
      ),
    );
  }
}
