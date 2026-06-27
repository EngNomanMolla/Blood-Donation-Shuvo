import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  static const String _keyHasShownOnboarding = 'has_shown_onboarding';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserToken = 'user_token';

  bool get hasShownOnboarding => _prefs.getBool(_keyHasShownOnboarding) ?? false;
  
  Future<bool> setHasShownOnboarding(bool value) async {
    return await _prefs.setBool(_keyHasShownOnboarding, value);
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<bool> setIsLoggedIn(bool value) async {
    return await _prefs.setBool(_keyIsLoggedIn, value);
  }

  String? get userToken => _prefs.getString(_keyUserToken);

  Future<bool> setUserToken(String token) async {
    return await _prefs.setString(_keyUserToken, token);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserToken);
  }
}
