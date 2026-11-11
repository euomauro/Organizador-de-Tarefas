import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Preferências do usuário: tema e onboarding.
class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingDone = false;

  ThemeMode get themeMode => _themeMode;
  bool get onboardingDone => _onboardingDone;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(AppConstants.themeKey);
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
      _onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;
    } catch (_) {
      // Mantém os padrões se as preferências não puderem ser lidas.
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeKey, mode.name);
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingKey, true);
    } catch (_) {}
  }
}
