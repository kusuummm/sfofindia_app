import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _blogs = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _fallbackArticles = [
    {
      'id': 1,
      'title': 'Honoring Our Bravehearts: Foundation Disburses Education Grants for 40 Martyr Children',
      'slug': 'honoring-our-bravehearts-education-grants',
      'category': 'Welfare Updates',
      'author': 'Shaheed Foundation Bureau',
      'image': 'assets/images/education-child.webp',
      'created_at': '2026-08-15',
      'views': 1420,
      'summary':
          'In a solemn ceremony commemorating national independence, the Shaheed Foundation handed over scholarship cheques covering tuition and academic materials for children of fallen armed forces heroes.',
      'content':
          'Shaheed Foundation of India has officially disbursed comprehensive educational grants for the 2026-27 academic term. Under our flagship Children\'s Higher Education Scholarship, 40 dependents of fallen heroes received financial support directly credited to verified beneficiary accounts.\n\n"Every child of a martyr carries the legacy of supreme bravery. Our responsibility as a nation is to ensure that no economic obstacle hinders their educational journey," stated Foundation leadership during the distribution drive in Gurugram.\n\nKey beneficiaries include school-going children and university students pursuing engineering, medical, and defense preparation degrees.',
    },
    {
      'id': 2,
      'title': 'Amar Jyoti Remembrance: National Tribute Ceremonies Observed Across State Chapters',
      'slug': 'amar-jyoti-remembrance-ceremony',
      'category': 'Memorial Events',
      'author': 'Editorial Team',
      'image': 'assets/images/Army.jpg',
      'created_at': '2026-07-26',
      'views': 2100,
      'summary':
          'Thousands of citizens joined foundation volunteers in lighting the eternal Amar Jyoti flame in honor of the martyrs of Kargil and border defense operations.',
      'content':
          'On the solemn occasion of Kargil Vijay Diwas, Shaheed Foundation chapters nationwide organized unified memorial tributes and Diya lighting ceremonies. Citizens from all walks of life contributed to the National Gratitude Wall, leaving heartfelt messages of remembrance for our brave soldiers.\n\nFoundation volunteers also facilitated Veer Nari welfare interactions, resolving pension documentation issues and handing over medical emergency assistance packs.',
    },
    {
      'id': 3,
      'title': 'Healthcare & Critical Mobility Assistance Camp for Disabled Veterans and Veer Naris',
      'slug': 'healthcare-mobility-camp-disabled-veterans',
      'category': 'Healthcare',
      'author': 'Medical Welfare Wing',
      'image': 'assets/images/health.jpg',
      'created_at': '2026-06-10',
      'views': 980,
      'summary':
          'Specialized orthopedic and geriatric health consultations provided alongside distribution of motorized wheelchairs and medical kits.',
      'content':
          'The Foundation organized a two-day dedicated health and mobility camp in Haryana. Over 150 war-disabled veterans, Veer Naris, and elderly martyr parents received specialized health screenings, free chronic medicine supplies for 6 months, and modern assistive devices including wheelchairs and hearing aids.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getBlogs();
      if (mounted && res.isSuccess && res.data is List && (res.data as List).isNotEmpty) {
        setState(() {
          _blogs = res.data as List;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _blogs = _fallbackArticles;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredBlogs {
    return _blogs.where((b) {
      final title = (b['title'] ?? '').toString().toLowerCase();
      final cat = (b['category'] ?? '').toString();
      final matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || cat.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();
  }

  List<String> get _categories {
    final Set<String> cats = {'All'};
    for (var b in _blogs) {
      if (b['category'] != null && b['category'].toString().trim().isNotEmpty) {
        cats.add(b['category'].toString().trim());
      }
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('News & Press Releases'),
        backgroundColor: AppTheme.secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBlogs,
        color: AppTheme.primaryGold,
        child: CustomScrollView(
          slivers: [
            // Top Header Banner
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF59E0B).withAlpha(100)),
                          ),
                          child: const Text(
                            'OFFICIAL DISPATCHES',
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Stories of Hope, Remembrance & Welfare Impact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Keep up with the latest programs, relief disbursements, and memorial ceremonies nationwide.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search articles, events, or updates...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        filled: true,
                        fillColor: Colors.white.withAlpha(15),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Pills
            SliverToBoxAdapter(
              child: Container(
                height: 52,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSel = _selectedCategory == cat;
                    return Center(
                      child: FilterChip(
                        selected: isSel,
                        label: Text(cat),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.white : const Color(0xFF334155),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.secondaryNavy,
                        checkmarkColor: AppTheme.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSel ? AppTheme.secondaryNavy : const Color(0xFFCBD5E1)),
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main Articles List
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              )
            else if (_filteredBlogs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.newspaper_outlined, size: 56, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'No articles found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredBlogs[index];
                      return _buildArticleCard(item);
                    },
                    childCount: _filteredBlogs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(dynamic item) {
    final title = item['title']?.toString() ?? 'Official Notice';
    final category = item['category']?.toString() ?? 'News';
    final summary = item['summary']?.toString() ?? (item['content']?.toString() ?? '');
    final dateStr = item['created_at']?.toString() ?? '';
    String displayDate = 'Recent';
    if (dateStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateStr);
        displayDate = DateFormat('dd MMM yyyy').format(parsed);
      } catch (_) {
        displayDate = dateStr;
      }
    }

    final image = item['image']?.toString() ?? item['featured_image']?.toString() ?? 'assets/images/carousel-1.jpg';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlogDetailScreen(article: Map<String, dynamic>.from(item as Map)),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                image.startsWith('assets/')
                    ? Image.asset(
                        image,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                      )
                    : Image.network(
                        image.startsWith('http') ? image : '${_apiService.baseUrl}/$image',
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                      ),
                PositionBorderChip(label: category),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        displayDate,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.access_time_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      const Text(
                        '3 min read',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Read Full Article',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFD97706)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 170,
      color: AppTheme.secondaryNavy,
      child: const Center(
        child: Icon(Icons.newspaper, size: 48, color: Colors.white54),
      ),
    );
  }
}

class PositionBorderChip extends StatelessWidget {
  final String label;
  const PositionBorderChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFBBF24),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
