import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  LocalStorageService(this._prefs);
  final SharedPreferences _prefs;

  // ==================== THEME ====================

  static const String _themeKey = 'app_theme';

  Future<void> saveTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String getTheme() {
    return _prefs.getString(_themeKey) ?? 'light';
  }

  // ==================== ONBOARDING ====================

  static const String _onboardingKey = 'has_seen_onboarding';

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  bool hasSeenOnboarding() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // ==================== LANGUAGE ====================

  static const String _languageKey = 'app_language';

  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'es';
  }

  // ==================== GENERIC ====================

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Clean all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}