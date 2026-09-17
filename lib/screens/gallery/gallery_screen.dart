import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/app_repository.dart';
import '../../models/gallery_event_model.dart';
import '../../services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ApiService _apiService = ApiService();
  List<GalleryItem> _galleryItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _galleryItems = List.from(AppRepository().gallery);
    _loadLiveGallery();
  }

  Future<void> _loadLiveGallery() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getGallery();
      if (res.isSuccess && res.data is List) {
        final List livePhotos = res.data as List;
        final List<GalleryItem> liveItems = [];

        for (int i = 0; i < livePhotos.length; i++) {
          final p = livePhotos[i];
          final rawPath = (p['image_path'] ?? p['image'] ?? '').toString();
          if (rawPath.isEmpty) continue;

          String imgUrl = rawPath;
          if (!rawPath.startsWith('http') && !rawPath.startsWith('assets/')) {
            final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
            imgUrl = '${_apiService.baseUrl}/$cleanPath';
          }

          liveItems.add(
            GalleryItem(
              id: 'live_${p['id'] ?? i}',
              title: p['title']?.toString() ?? 'Community Drive Photo',
              imagePath: imgUrl,
              tag: 'Foundation Drive',
            ),
          );
        }

        if (liveItems.isNotEmpty && mounted) {
          setState(() {
            // Put live uploads at top, followed by curated gallery albums
            _galleryItems = [...liveItems, ...AppRepository().gallery];
          });
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGalleryImage(String path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => Container(
          height: height,
          width: width,
          color: AppTheme.secondaryNavy.withAlpha(20),
          child: const Center(child: Icon(Icons.photo, color: AppTheme.secondaryNavy)),
        ),
      );
    }
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        height: height,
        width: width,
        color: AppTheme.secondaryNavy.withAlpha(20),
        child: const Center(child: Icon(Icons.photo, color: AppTheme.secondaryNavy)),
      ),
    );
  }

  void _showImageDialog(BuildContext context, GalleryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildGalleryImage(item.imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery & Events'),
          backgroundColor: AppTheme.secondaryNavy,
          actions: [
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Sync with Website',
              onPressed: _isLoading ? null : _loadLiveGallery,
            ),
          ],
        ),
        body: Column(
          children: [
            // Website Page Header Banner: Navy with Gold Bottom Border
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppTheme.secondaryNavy,
                border: Border(
                  bottom: BorderSide(color: AppTheme.primaryGold, width: 3),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Gallery & Welfare Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                        '  /  Gallery',
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

            // Tab bar styled with website Gold/Navy
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: AppTheme.primaryGold,
                indicatorWeight: 3,
                labelColor: AppTheme.secondaryNavy,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(icon: Icon(Icons.photo_library_outlined), text: 'Photo Gallery'),
                  Tab(icon: Icon(Icons.event_outlined), text: 'Welfare Events'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Gallery Grid Tab
                  RefreshIndicator(
                    onRefresh: _loadLiveGallery,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = Responsive.galleryColumns(width);
                        final ratio = width < 360 ? 0.82 : (width < 600 ? 0.90 : 1.0);

                        return ResponsiveContainer(
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _galleryItems.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: ratio,
                            ),
                            itemBuilder: (context, index) {
                              final item = _galleryItems[index];
                              return InkWell(
                                onTap: () => _showImageDialog(context, item),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.cardBorder),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildGalleryImage(
                                          item.imagePath,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGold.withAlpha(25),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.tag,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryGoldDark,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
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
                        );
                      },
                    ),
                  ),

                  // Events List Tab
                  RefreshIndicator(
                    onRefresh: _loadLiveGallery,
                    child: ResponsiveContainer(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: repo.events.length,
                        itemBuilder: (context, index) {
                      final ev = repo.events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              ev.imagePath,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 130,
                                color: AppTheme.secondaryNavy,
                                child: const Center(child: Icon(Icons.event, color: Colors.white30, size: 40)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryNavy,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          ev.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryGoldDark),
                                      const SizedBox(width: 4),
                                      Text(
                                        ev.date,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGoldDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    ev.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondaryNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          ev.location,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ev.description,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
}
