import 'package:flutter/material.dart';

class AppLocale extends ChangeNotifier {
  static final AppLocale _instance = AppLocale._internal();
  factory AppLocale() => _instance;
  AppLocale._internal();

  String _currentLanguage = 'en'; // 'en' or 'hi'

  String get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == 'hi';
  String get displayName => isHindi ? 'हिंदी' : 'English';

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void setLanguage(String code) {
    if (code == 'en' || code == 'hi') {
      _currentLanguage = code;
      notifyListeners();
    }
  }

  String translate(String key) {
    if (_currentLanguage == 'hi') {
      return _hindiTranslations[key] ?? _englishTranslations[key] ?? key;
    }
    return _englishTranslations[key] ?? key;
  }

  String t(String key) => translate(key);

  static final Map<String, String> _englishTranslations = {
    // Navigation
    'nav_home': 'Home',
    'nav_services': 'Support Services',
    'nav_donate': 'Donate (80G)',
    'nav_members': 'Members',
    'nav_memorial': 'Amar Jawan Memorial',
    'nav_schemes': 'Govt Welfare Schemes',
    'nav_volunteer': 'Blood & Volunteers',
    'nav_calculator': '80G Tax Calculator',
    'nav_aid': 'Apply for Aid',
    'nav_news': 'News & Bulletins',
    'nav_stories': 'Impact Stories',
    'nav_emergency': 'Emergency SOS',
    'nav_login': 'Login Portal',

    // Branding & Headers
    'app_name': 'SHAHEED FOUNDATION',
    'tagline': 'Honoring Sacrifice. Supporting Families. Building Hope.',
    'govt_registered': 'Section 8 Registered Non-Profit • Govt of India',
    'quick_tools': 'QUICK SERVICES & TOOLS',
    'emergency_helpline': '24x7 Emergency Helpline',
    'light_diya': 'Light Amar Jyoti',
    'tributes_paid': 'Tributes Paid',
    'stand_with_heroes': 'Standing With Those Who Gave Everything',
  };

  static final Map<String, String> _hindiTranslations = {
    // Navigation
    'nav_home': 'होम (मुख्य पृष्ठ)',
    'nav_services': 'कल्याणकारी सेवाएं',
    'nav_donate': 'दान करें (80G छूट)',
    'nav_members': 'सदस्यता एवं सत्यापन',
    'nav_memorial': 'अमर जवान स्मृति पटल',
    'nav_schemes': 'सैनिक कल्याणकारी योजनाएं',
    'nav_volunteer': 'रक्तदाता एवं स्वयंसेवक केंद्र',
    'nav_calculator': '80G टैक्स बचत कैलकुलेटर',
    'nav_aid': 'शहीद परिवार सहायता आवेदन',
    'nav_news': 'समाचार एवं बुलेटिन',
    'nav_stories': 'प्रेरणादायक कहानियां',
    'nav_emergency': 'आपातकालीन सहायता (SOS)',
    'nav_login': 'लॉगिन पोर्टल',

    // Branding & Headers
    'app_name': 'शहीद फाउंडेशन ऑफ इंडिया',
    'tagline': 'सर्वोच्च बलिदान को नमन। परिवारों का संबल। नए भविष्य का निर्माण।',
    'govt_registered': 'धारा 8 पंजीकृत गैर-लाभकारी न्यास • भारत सरकार',
    'quick_tools': 'त्वरित सेवाएं एवं सुविधाएं',
    'emergency_helpline': '24x7 आपातकालीन हेल्पलाइन',
    'light_diya': 'अमर ज्योति प्रज्वलित करें',
    'tributes_paid': 'श्रद्धांजलि अर्पित',
    'stand_with_heroes': 'देश के वीर शहीदों के परिवारों के साथ सदैव तत्पर',
  };
}
