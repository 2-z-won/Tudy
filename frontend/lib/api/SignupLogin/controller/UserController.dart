import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:frontend/api/SignupLogin/model/UserModel.dart';

class UserController {
  // 사용자 정보 조회
  static Future<User?> getUserInfo(String userId) async {
    try {
      final token = await getTokenFromStorage();
      final uri = Uri.parse('${Urls.apiUrl}users/$userId');
      
      print('🔍 사용자 정보 API 호출: $uri');
      print('🔍 토큰: ${token?.substring(0, 20)}...');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🟡 사용자 정보 응답 상태: ${response.statusCode}');
      print('🟡 사용자 정보 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        final user = User.fromJson(userData);
        print('✅ 사용자 정보 조회 성공: ${user.name}');
        return user;
      } else {
        print('🔥 사용자 정보 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 사용자 정보 조회 중 에러: $e');
      return null;
    }
  }

  // 사용자 정보 업데이트
  static Future<bool> updateUserInfo(String userId, Map<String, dynamic> updateData) async {
    try {
      final token = await getTokenFromStorage();
      final uri = Uri.parse('${Urls.apiUrl}users/$userId');
      
      print('🔍 사용자 정보 업데이트 API 호출: $uri');
      print('🔍 업데이트 데이터: $updateData');
      
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      print('🟡 사용자 정보 업데이트 응답 상태: ${response.statusCode}');
      print('🟡 사용자 정보 업데이트 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ 사용자 정보 업데이트 성공');
        return true;
      } else {
        print('🔥 사용자 정보 업데이트 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🔥 사용자 정보 업데이트 중 에러: $e');
      return false;
    }
  }
}
