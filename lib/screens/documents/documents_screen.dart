import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_repository.dart';
import '../../models/document_model.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  void _showDocumentPreview(BuildContext context, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryNavy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.primaryGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        doc.assetPath,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 180,
                          color: AppTheme.warmCream,
                          child: const Center(
                            child: Icon(Icons.description,
                                size: 64, color: AppTheme.secondaryNavy),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _docDetailRow('Document No.', doc.registrationOrDocNumber),
                    _docDetailRow('Issuing Authority', doc.issuingAuthority),
                    _docDetailRow('Category', doc.category),
                    _docDetailRow('Date of Issue', doc.dateOfIssue),
                    const Divider(height: 20),
                    Text(
                      doc.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: AppTheme.textDark,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document opened / downloaded'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download Official Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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

  static Widget _docDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            const Text('Our Documents'),
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
                  'Our Documents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      ' /  Our Documents',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag & Title
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 3,
                      color: AppTheme.primaryGold,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TRANSPARENCY',
                      style: TextStyle(
                        color: AppTheme.primaryGoldDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Official Documents & Certificates',
                  style: TextStyle(
                    color: AppTheme.secondaryNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'SHAHEED FOUNDATION is a registered Section 8 company. Below are our key registration documents, licences, and approvals for your reference.',
                  style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // PAN Card Featured Section (from documents.php)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Image.asset(
                        AppConstants.panCardPath,
                        width: double.infinity,
                        height: 190,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 160,
                          color: AppTheme.warmCream,
                          child: const Center(
                            child: Icon(Icons.badge, size: 50, color: AppTheme.secondaryNavy),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        color: AppTheme.warmCream,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.open_in_new, size: 14, color: AppTheme.primaryGoldDark),
                            SizedBox(width: 6),
                            Text(
                              'PAN Card — Income Tax Department, Govt of India',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Document cards grid
                const Text(
                  'Statutory Registrations & Licenses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
                const SizedBox(height: 12),

                ...repo.documents.map((doc) => _buildDocCard(context, doc)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, DocumentModel doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showDocumentPreview(context, doc),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryGold),
                ),
                child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryGoldDark, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.issuingAuthority,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.download, color: AppTheme.primaryGoldDark, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
