import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getTokenFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<String?> getUserIdFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
}
