import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/localization/app_locale.dart';

void main() {
  test('AppLocale switches languages and resolves translation keys', () {
    final locale = AppLocale();
    locale.setLanguage('en');
    expect(locale.isHindi, isFalse);
    expect(locale.translate('nav_home'), 'Home');

    locale.toggleLanguage();
    expect(locale.isHindi, isTrue);
    expect(locale.translate('nav_home'), 'होम (मुख्य पृष्ठ)');

    // Toggle back to English
    locale.setLanguage('en');
    expect(locale.isHindi, isFalse);
  });
}
