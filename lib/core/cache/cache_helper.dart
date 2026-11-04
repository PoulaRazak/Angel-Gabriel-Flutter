import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static const String _keyToken = 'ag_auth_token';
  static const String _keyUserId = 'ag_user_id';
  static const String _keyUserName = 'ag_user_name';
  static const String _keyUserPhone = 'ag_user_phone';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveSession({
    required String token,
    required String userId,
    required String fullName,
    required String phone,
  }) async {
    await init();
    await _prefs!.setString(_keyToken, token);
    await _prefs!.setString(_keyUserId, userId);
    await _prefs!.setString(_keyUserName, fullName);
    await _prefs!.setString(_keyUserPhone, phone);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static String? getUserId() {
    return _prefs?.getString(_keyUserId);
  }

  static String? getUserName() {
    return _prefs?.getString(_keyUserName);
  }

  static String? getUserPhone() {
    return _prefs?.getString(_keyUserPhone);
  }

  static bool isLoggedIn() {
    final token = getToken();
    final userId = getUserId();
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await init();
    await _prefs!.remove(_keyToken);
    await _prefs!.remove(_keyUserId);
    await _prefs!.remove(_keyUserName);
    await _prefs!.remove(_keyUserPhone);
  }
}
