import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_helper.dart';
import '../../services/api_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String? ticketId;
    try {
      final res = await ApiService().submitContact(data: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim().isEmpty ? 'General Inquiry' : _subjectCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
      });

      if (res.isSuccess && res.data != null && res.data is Map) {
        ticketId = (res.data as Map)['ticket_id']?.toString();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primaryGoldDark, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message Sent Successfully',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
            ),
            const SizedBox(height: 8),
            Text(
              ticketId != null
                  ? 'Your inquiry tracking ticket is $ticketId.\nOur administrative team will respond promptly.'
                  : 'Thank you for reaching out to Shaheed Foundation of India. Our administrative team will respond to your inquiry shortly.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: AppTheme.textDark,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _nameCtrl.clear();
                  _emailCtrl.clear();
                  _phoneCtrl.clear();
                  _subjectCtrl.clear();
                  _msgCtrl.clear();
                },
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('Contact'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Contact',
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
                        ' /  Contact',
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
                  // Title Tag
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 3,
                        color: AppTheme.primaryGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CONTACT',
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
                    'If You Have Any Query, Please Contact Us',
                    style: TextStyle(
                      color: AppTheme.secondaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Our help desk and welfare support officers are available to answer queries, support donors, and assist martyr families.',
                    style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),

                  // Contact Information Cards
                  _contactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Call Us Directly',
                    subtitle: AppConstants.phoneDisplay,
                    actionLabel: 'Call Now',
                    onTap: () => UrlHelper.launchPhoneCall(context, AppConstants.phone),
                  ),
                  _contactCard(
                    icon: Icons.email_rounded,
                    title: 'Official Email',
                    subtitle: AppConstants.email,
                    actionLabel: 'Send Email',
                    onTap: () => UrlHelper.launchEmail(context, AppConstants.email),
                  ),
                  _contactCard(
                    icon: Icons.location_on_rounded,
                    title: 'Registered Office',
                    subtitle: AppConstants.address,
                    actionLabel: 'Copy Address',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: AppConstants.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard')),
                      );
                    },
                  ),
                  _contactCard(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Business Hours',
                    subtitle: 'Mon - Fri: 09:00 am - 07:00 pm\nSat: 09:00 am - 12:00 pm\nSun: Closed',
                    actionLabel: 'Active',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Contact Form from contact.php
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Need a functional contact form?',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'The contact form is currently active. Send us your details and we will get back to you soon.',
                            style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Your Name *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Your Email *',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number *',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (v) => v == null || v.trim().length < 10 ? 'Enter a valid phone number' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _subjectCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Subject *',
                              prefixIcon: Icon(Icons.subject_outlined),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter subject' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _msgCtrl,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Message *',
                              hintText: 'Write your message...',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your message' : null,
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: AppTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _submitMessage,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.textDark,
                                      ),
                                    )
                                  : const Text(
                                      'Send Message',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGoldDark,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
