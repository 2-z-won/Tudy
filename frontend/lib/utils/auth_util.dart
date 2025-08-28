import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getTokenFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<String?> getUserIdFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
}

/*
class AuthUtil {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<Map<String, String>> authHeaders({
    Map<String, String>? base,
  }) async {
    final token = await getAccessToken();
    return {
      if (base != null) ...base,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
}*/
