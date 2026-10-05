import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'url_platform_launcher.dart';

class UrlHelper {
  /// Opens the device dialer with the phone number pre-filled.
  static Future<void> launchPhoneCall(BuildContext context, [String? rawPhone]) async {
    final phone = rawPhone ?? AppConstants.phone;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final telUrl = 'tel:$cleanPhone';

    if (kIsWeb) {
      try {
        platformLaunchUrl(telUrl);
        return;
      } catch (e) {
        debugPrint('Web dialer error: $e');
      }
    }

    final uri = Uri.parse(telUrl);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );
      if (!success) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Dialer launch error: ');
      await Clipboard.setData(ClipboardData(text: phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
            content: Text('Helpline copied: $phone'),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Opens the device default email client.
  static Future<void> launchEmail(BuildContext context, [String? email]) async {
    final targetEmail = email ?? AppConstants.email;
    final mailtoUrl = 'mailto:$targetEmail';

    if (kIsWeb) {
      try {
        platformLaunchUrl(mailtoUrl);
        return;
      } catch (e) {
        debugPrint('Web mailto error: $e');
      }
    }

    final uri = Uri.parse(mailtoUrl);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );
      if (!success) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Email launch error: $e');
      await Clipboard.setData(ClipboardData(text: targetEmail));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email copied: $targetEmail'),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Opens an external web URL in the device browser.
  static Future<void> launchWebUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching web URL: $e');
    }
  }
}
