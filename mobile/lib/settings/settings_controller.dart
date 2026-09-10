import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { french, english }

class SettingsController extends ChangeNotifier {
  SettingsController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null;

  static const _soundKey = 'settings.sound_enabled';
  static const _musicKey = 'settings.music_enabled';
  static const _vibrationsKey = 'settings.vibrations_enabled';
  static const _notificationsKey = 'settings.notifications_enabled';
  static const _languageKey = 'settings.language';
  static const _onboardingKey = 'settings.onboarding_complete';

  final SharedPreferencesAsync? _preferences;

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationsEnabled = true;
  bool notificationsEnabled = false;
  AppLanguage language = AppLanguage.french;
  bool onboardingComplete = false;

  bool get isFrench => language == AppLanguage.french;

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) return;

    soundEnabled = await preferences.getBool(_soundKey) ?? true;
    musicEnabled = await preferences.getBool(_musicKey) ?? true;
    vibrationsEnabled = await preferences.getBool(_vibrationsKey) ?? true;
    notificationsEnabled =
        await preferences.getBool(_notificationsKey) ?? false;
    onboardingComplete = await preferences.getBool(_onboardingKey) ?? false;

    final savedLanguage = await preferences.getString(_languageKey);
    language = savedLanguage == AppLanguage.english.name
        ? AppLanguage.english
        : AppLanguage.french;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_soundKey, value);
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_musicKey, value);
  }

  Future<void> setVibrationsEnabled(bool value) async {
    vibrationsEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_vibrationsKey, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_notificationsKey, value);
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    await _preferences?.setString(_languageKey, value.name);
  }

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    notifyListeners();
    await _preferences?.setBool(_onboardingKey, true);
  }

  Future<void> resetAllData() async {
    await _preferences?.clear();
    soundEnabled = true;
    musicEnabled = true;
    vibrationsEnabled = true;
    notificationsEnabled = false;
    language = AppLanguage.french;
    onboardingComplete = false;
    notifyListeners();
  }
}
