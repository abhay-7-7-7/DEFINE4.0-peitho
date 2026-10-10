import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isStatic;
  final bool rtl;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isStatic = false,
    this.rtl = false,
  });
}

/// 50+ languages matching TradeMind web list
const List<LanguageInfo> supportedLanguages = [
  LanguageInfo(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸', isStatic: true),
  LanguageInfo(code: 'hi', name: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳', isStatic: true),
  LanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦', isStatic: false, rtl: true),
  LanguageInfo(code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱', isStatic: false, rtl: true),
  LanguageInfo(code: 'fa', name: 'Persian', nativeName: 'فارسی', flag: '🇮🇷', isStatic: false, rtl: true),
  LanguageInfo(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰', isStatic: false, rtl: true),
  LanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸', isStatic: false),
  LanguageInfo(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷', isStatic: false),
  LanguageInfo(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪', isStatic: false),
  LanguageInfo(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵', isStatic: false),
  LanguageInfo(code: 'zh', name: 'Chinese', nativeName: '简体中文', flag: '🇨🇳', isStatic: false),
  LanguageInfo(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷', isStatic: false),
  LanguageInfo(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺', isStatic: false),
  LanguageInfo(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩', isStatic: false),
  LanguageInfo(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳', isStatic: false),
  LanguageInfo(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳', isStatic: false),
];

/// Built-in English static dictionary
const Map<String, String> _enStrings = {
  'app.name': 'TradeMind',
  'app.tagline': 'Autonomous & Assisted Commercial Negotiation',
  'auth.login': 'Seller Login',
  'auth.register': 'Create Account',
  'auth.email': 'Email Address',
  'auth.password': 'Password',
  'auth.fullname': 'Full Name',
  'auth.logout': 'Sign Out',
  'nav.dashboard': 'Dashboard',
  'nav.products': 'Products',
  'nav.assist': 'Live Assist',
  'nav.chatbot': 'Bot Demo',
  'nav.analytics': 'Analytics',
  'nav.settings': 'Settings',
  'nav.buyer': 'Join as Buyer',
  'common.loading': 'Loading...',
  'common.save': 'Save',
  'common.cancel': 'Cancel',
  'common.retry': 'Retry',
  'common.error': 'An error occurred',
  'buyer.title': 'TradeMind Live Negotiation',
  'buyer.scan_qr': 'Scan QR Code',
  'buyer.paste_link': 'Paste Link or Token',
  'buyer.your_name': 'Your Name',
  'buyer.enter_room': 'Join Room',
  'buyer.placeholder': 'Type your offer or counter...',
  'seller.assist_title': 'PRANE-X Negotiation Assist',
  'seller.profit_radar': 'Profitability Radar',
  'seller.detected_offer': 'Detected Offer',
  'seller.unit_profit': 'Unit Profit',
  'seller.margin': 'Margin',
  'seller.total_profit': 'Total Profit',
  'seller.discount_vs_base': 'Discount vs Base',
  'seller.gap_to_floor': 'Gap to Floor',
  'seller.use_reply': 'Use this reply',
  'seller.loss_warning': 'CRITICAL FLOOR VIOLATION: Offer is BELOW floor price',
};

/// Built-in Hindi static dictionary
const Map<String, String> _hiStrings = {
  'app.name': 'ट्रेडमाइंड',
  'app.tagline': 'स्वचालित एवं सह-सहायक व्यावसायिक बातचीत',
  'auth.login': 'विक्रेता लॉगिन',
  'auth.register': 'खाता बनाएं',
  'auth.email': 'ईमेल पता',
  'auth.password': 'पासवर्ड',
  'auth.fullname': 'पूरा नाम',
  'auth.logout': 'लॉग आउट',
  'nav.dashboard': 'डैशबोर्ड',
  'nav.products': 'उत्पाद',
  'nav.assist': 'लाइव सहायता',
  'nav.chatbot': 'बॉट डेमो',
  'nav.analytics': 'एनालिटिक्स',
  'nav.settings': 'सेटिंग्स',
  'nav.buyer': 'खरीदार के रूप में जुड़ें',
  'common.loading': 'लोड हो रहा है...',
  'common.save': 'सहेजें',
  'common.cancel': 'रद्द करें',
  'common.retry': 'पुनः प्रयास करें',
  'common.error': 'एक त्रुटि हुई',
  'buyer.title': 'ट्रेडमाइंड लाइव बातचीत',
  'buyer.scan_qr': 'क्यूआर कोड स्कैन करें',
  'buyer.paste_link': 'लिंक या टोकन पेस्ट करें',
  'buyer.your_name': 'आपका नाम',
  'buyer.enter_room': 'कमरे में शामिल हों',
  'buyer.placeholder': 'अपना प्रस्ताव या संदेश लिखें...',
  'seller.assist_title': 'PRANE-X बातचीत सहायता',
  'seller.profit_radar': 'लाभ रडार',
  'seller.detected_offer': 'पहचाना गया प्रस्ताव',
  'seller.unit_profit': 'इकाई लाभ',
  'seller.margin': 'मार्जिन',
  'seller.total_profit': 'कुल लाभ',
  'seller.discount_vs_base': 'आधार से छूट',
  'seller.gap_to_floor': 'न्यूनतम सीमा से अंतर',
  'seller.use_reply': 'इस उत्तर का उपयोग करें',
  'seller.loss_warning': 'गंभीर चेतावनी: यह प्रस्ताव न्यूनतम सीमा से नीचे है',
};

class AppLocalizations {
  final String localeCode;
  final Map<String, String> _dynamicCache;

  AppLocalizations(this.localeCode, [this._dynamicCache = const {}]);

  bool get isRTL {
    final info = supportedLanguages.firstWhere(
      (l) => l.code == localeCode,
      orElse: () => supportedLanguages.first,
    );
    return info.rtl;
  }

  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  String t(String key) {
    if (_dynamicCache.containsKey(key)) {
      return _dynamicCache[key]!;
    }
    if (localeCode == 'hi' && _hiStrings.containsKey(key)) {
      return _hiStrings[key]!;
    }
    return _enStrings[key] ?? key;
  }
}

class AppLocaleNotifier extends StateNotifier<AppLocalizations> {
  static const _prefKey = 'trademind_locale';

  AppLocaleNotifier() : super(AppLocalizations('en')) {
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'en';
      state = AppLocalizations(code);
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    state = AppLocalizations(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }

  void updateDynamicCache(Map<String, String> newTranslations) {
    state = AppLocalizations(state.localeCode, {
      ...state._dynamicCache,
      ...newTranslations,
    });
  }
}

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLocalizations>((ref) {
  return AppLocaleNotifier();
});
