import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class ServerConnectionDialog extends StatefulWidget {
  const ServerConnectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ServerConnectionDialog(),
    );
  }

  @override
  State<ServerConnectionDialog> createState() => _ServerConnectionDialogState();
}

class _ServerConnectionDialogState extends State<ServerConnectionDialog> {
  final ApiService _apiService = ApiService();
  late final TextEditingController _urlController;

  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  final List<Map<String, String>> _presets = [
    {
      'label': 'Live Pinggy Tunnel (Port 8099)',
      'url': 'https://edzaj-2405-201-5c32-2839-51f9-a6ed-4947-6a06.free.pinggy.net',
    },
    {
      'label': 'Live Pinggy Alt (run.pinggy-free.link)',
      'url': 'https://vuwif-2405-201-5c32-2839-51f9-a6ed-4947-6a06.run.pinggy-free.link',
    },
    {
      'label': 'Localhost (127.0.0.1:8099)',
      'url': 'http://127.0.0.1:8099',
    },
    {
      'label': 'Android Emulator (10.0.2.2:8099)',
      'url': 'http://10.0.2.2:8099',
    },
    {
      'label': 'Official Website (sfofindia.com)',
      'url': 'https://sfofindia.com',
    },
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _apiService.baseUrl);
    _testSuccess = _apiService.isBackendReachable;
    if (_apiService.isBackendReachable) {
      _testResult = 'Currently connected';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleTest() async {
    final testUrl = _urlController.text.trim();
    if (testUrl.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final res = await _apiService.testUrlConnection(testUrl);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = res.isSuccess;
      _testResult = res.isSuccess
          ? (res.message ?? 'Connected successfully!')
          : (res.message ?? 'Failed to connect. Check IP and Wi-Fi.');
    });
  }

  Future<void> _handleSave() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    await _apiService.saveCustomBaseUrl(url);
    final health = await _apiService.checkHealth();

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          health.isSuccess
              ? 'Connected to server at $url'
              : 'Saved server URL. (Offline / waiting for server)',
        ),
        backgroundColor: health.isSuccess ? AppTheme.wreathGreen : Colors.orange.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.dns_rounded, color: AppTheme.secondaryNavy),
          SizedBox(width: 10),
          Text(
            'Server Connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Specify your backend server address. For physical phones, use your PC Wi-Fi IP.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),

            // Server URL Input
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Backend Base URL',
                hintText: 'http://192.168.29.171:8099',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Presets
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _presets.map((preset) {
                return ActionChip(
                  label: Text(preset['label']!, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppTheme.warmCreamLight,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () {
                    setState(() {
                      _urlController.text = preset['url']!;
                      _testResult = null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Test connection result banner
            if (_testResult != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess ? Colors.green.shade700 : Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 11,
                          color: _testSuccess ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Wi-Fi note
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ensure Phone and PC are on the same Wi-Fi and "start_backend.bat" is running.',
                      style: TextStyle(fontSize: 10.5, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTesting ? null : _handleTest,
          child: _isTesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Test Ping'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }
}
