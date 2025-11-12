import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'es';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      _locale = const Locale('es');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  void toggleLanguage() {
    final newLocale = _locale.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    setLocale(newLocale);
  }
}