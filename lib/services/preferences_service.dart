import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<bool> getHasOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasOpened') ?? false;
  }

  Future<void> setHasOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOpened', true);
  }
}