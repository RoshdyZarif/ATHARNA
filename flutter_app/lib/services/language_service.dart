import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == 'ar';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
    } else {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _currentLanguage = deviceLocale == 'ar' ? 'ar' : 'en';
      await prefs.setString('language', _currentLanguage);
    }
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLanguage);
    notifyListeners();
  }

  String translate(String key, Map<String, Map<String, String>> translations) =>
      translations[key]?[_currentLanguage] ?? key;
}
