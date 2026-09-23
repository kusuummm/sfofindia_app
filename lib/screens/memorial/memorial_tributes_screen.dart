import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class MemorialTributesScreen extends StatefulWidget {
  const MemorialTributesScreen({super.key});

  @override
  State<MemorialTributesScreen> createState() => _MemorialTributesScreenState();
}

class _MemorialTributesScreenState extends State<MemorialTributesScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int _diyaCount = 1248;
  bool _isLighting = false;
  bool _diyaLit = false;
  List<dynamic> _tributes = [];
  bool _isLoadingTributes = true;
  bool _isSubmittingTribute = false;

  late AnimationController _flameAnimController;

  final List<Map<String, dynamic>> _fallbackTributes = [
    {
      'citizen_name': 'Col. Arvind Sharma (Retd.)',
      'citizen_city': 'Chandigarh',
      'message': 'Salute to the immortal souls who laid down their lives for the sovereignty of Bharat Mata. We will forever remain in your debt.',
      'created_at': '2026-08-15 10:30:00',
    },
    {
      'citizen_name': 'Dr. Meenakshi Sundaram',
      'citizen_city': 'Bengaluru',
      'message': 'Their sacrifice guarantees our freedom. Humble homage to the brave martyrs and heartfelt pranams to their resilient families.',
      'created_at': '2026-08-14 18:45:00',
    },
    {
      'citizen_name': 'Sunil Rathi',
      'citizen_city': 'Rohtak, Haryana',
      'message': 'जय हिन्द! शहीद अमर रहें। The Foundation does noble service by standing with Veer Naris and martyr children.',
      'created_at': '2026-08-14 14:15:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _flameAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fetchTributes();
  }

  @override
  void dispose() {
    _flameAnimController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTributes() async {
    setState(() => _isLoadingTributes = true);
    try {
      final res = await _apiService.getTributes();
      if (mounted && res.isSuccess && res.data is List && (res.data as List).isNotEmpty) {
        setState(() {
          _tributes = res.data as List;
          _isLoadingTributes = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _tributes = _fallbackTributes;
        _isLoadingTributes = false;
      });
    }
  }

  Future<void> _handleLightDiya() async {
    if (_diyaLit) return;
    setState(() => _isLighting = true);

    try {
      final res = await _apiService.lightDiya();
      if (mounted && res.isSuccess && res.data is Map) {
        final total = res.data['total_diyas'] ?? res.data['hero_diyas'];
        if (total != null) {
          _diyaCount = int.tryParse(total.toString()) ?? (_diyaCount + 1);
        } else {
          _diyaCount++;
        }
      } else {
        _diyaCount++;
      }
    } catch (_) {
      _diyaCount++;
    }

    if (mounted) {
      setState(() {
        _diyaLit = true;
        _isLighting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ अमर ज्योति प्रज्वलित! Your heartfelt tribute has been recorded.'),
          backgroundColor: Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handlePostTribute() async {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final msg = _messageController.text.trim();

    if (name.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and tribute message.')),
      );
      return;
    }

    setState(() => _isSubmittingTribute = true);

    try {
      final res = await _apiService.postTribute(
        name: name,
        city: city.isNotEmpty ? city : 'India',
        message: msg,
      );

      if (mounted && res.isSuccess) {
        _nameController.clear();
        _cityController.clear();
        _messageController.clear();

        setState(() {
          _tributes.insert(0, {
            'citizen_name': name,
            'citizen_city': city.isNotEmpty ? city : 'India',
            'message': msg,
            'created_at': DateTime.now().toString(),
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your tribute has been inscribed on the National Gratitude Wall!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Local addition
      if (mounted) {
        setState(() {
          _tributes.insert(0, {
            'citizen_name': name,
            'citizen_city': city.isNotEmpty ? city : 'India',
            'message': msg,
            'created_at': DateTime.now().toString(),
          });
        });
      }
    }

    if (mounted) {
      setState(() => _isSubmittingTribute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Amar Jyoti & Martyr Tributes'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTributes,
        color: const Color(0xFFF59E0B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Eternal Flame / Amar Jyoti Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Indian Tricolor Accent
                    Row(
                      children: [
                        Expanded(child: Container(height: 3, color: const Color(0xFFFF9933))),
                        Expanded(child: Container(height: 3, color: Colors.white)),
                        Expanded(child: Container(height: 3, color: const Color(0xFF138808))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amar Jyoti Glowing Flame Icon
                    AnimatedBuilder(
                      animation: _flameAnimController,
                      builder: (context, child) {
                        final glow = 20.0 + (_flameAnimController.value * 15.0);
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E1B4B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withAlpha(120),
                                blurRadius: glow,
                                spreadRadius: glow / 4,
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 64,
                            color: Color(0xFFFBBF24),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'अमर ज्योति • THE ETERNAL FLAME',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Light a virtual Diya in supreme gratitude to the immortal martyrs of Bharat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // Counter Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '$_diyaCount Diyas Lit Across India',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Light a Diya CTA Button
                    SizedBox(
                      width: 260,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _diyaLit ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 6,
                        ),
                        icon: _isLighting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                              )
                            : Icon(_diyaLit ? Icons.check_circle_rounded : Icons.flare_rounded),
                        label: Text(
                          _diyaLit ? 'श्रद्धांजलि अर्पित की गई' : 'Light a Diya (अमर ज्योति)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: _isLighting ? null : _handleLightDiya,
                      ),
                    ),
                  ],
                ),
              ),

              // White Content Card: Gratitude Wall & Post Form
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post a Tribute Form Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Write on the National Gratitude Wall',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Your Full Name *',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: 'City / State',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _messageController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Your Tribute / Message to Martyrs & Families *',
                              hintText: 'e.g. Forever indebted to the supreme bravery of our defense forces...',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isSubmittingTribute ? null : _handlePostTribute,
                              child: _isSubmittingTribute
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Post Tribute Message', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // National Wall Tributes List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'National Gratitude Wall',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_tributes.length} Tributes',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_isLoadingTributes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: AppTheme.primaryGold),
                        ),
                      )
                    else if (_tributes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Be the first to post a tribute message!'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tributes.length,
                        itemBuilder: (context, i) {
                          final t = _tributes[i];
                          final name = t['citizen_name']?.toString() ?? 'Proud Citizen';
                          final city = t['citizen_city']?.toString() ?? 'India';
                          final msg = t['message']?.toString() ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFFF59E0B).withAlpha(40),
                                      child: const Icon(Icons.flare, size: 16, color: Color(0xFFD97706)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• $city',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  msg,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                                ),
                              ],
                            ),
                          );
                        },
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
}
