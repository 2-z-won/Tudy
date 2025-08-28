import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class JoinGroupController extends GetxController {
  var messageType = "".obs; // "success", "error"
  var message = "".obs;

  Future<int?> searchGroupIdByName(String groupName) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse('${Urls.apiUrl}groups/search?name=$groupName');
    
    print('🔍 그룹 검색 API 호출: $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('🟡 그룹 검색 응답 상태: ${response.statusCode}');
    print('🟡 그룹 검색 응답 내용: ${response.body}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('🔍 파싱된 JSON: $json');
      
      if (json["exists"] == true) {
        final groupId = json["groupId"];
        print('✅ 그룹 발견 - ID: $groupId');
        return groupId;
      } else {
        messageType.value = "error";
        message.value = "존재하지 않는 그룹입니다.";
        return null;
      }
    } else {
      messageType.value = "error";
      message.value = "그룹 검색 실패: ${response.statusCode}";
      return null;
    }
  }

  Future<void> joinGroup({
    required int groupId,
    required String password,
  }) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse('${Urls.apiUrl}groups/join');
    
    print('🔍 그룹 가입 API 호출: $uri');
    print('🔍 요청 데이터: groupId=$groupId, password=$password');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "groupId": groupId,
        "password": password,
      }),
    );

    print('🟡 그룹 가입 응답 상태: ${response.statusCode}');
    print('🟡 그룹 가입 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      final messageResponse = jsonDecode(response.body);
      final msg = messageResponse["message"] ?? response.body;
      if (msg.contains("완료") || msg.contains("성공")) {
        messageType.value = "success";
      } else {
        messageType.value = "error";
      }
      message.value = msg;
    } else {
      messageType.value = "error";
      message.value = "그룹 가입 실패: ${response.statusCode}";
    }
  }
}
