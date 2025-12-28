import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppStateProvider extends ChangeNotifier {
  late Box _settingsBox;
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  AppStateProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = Hive.box('settings');
    _isDarkMode = _settingsBox.get('darkMode', defaultValue: false);
    final savedLocale = _settingsBox.get('locale', defaultValue: 'en');
    _locale = Locale(savedLocale);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _settingsBox.put('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _settingsBox.put('darkMode', value);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _settingsBox.put('locale', newLocale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }
}
