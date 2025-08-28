import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Group/model/AddGroupModel.dart';
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class GroupController extends GetxController {
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<void> createGroup(AddGroup group) async {
    final url = Uri.parse('${Urls.apiUrl}groups');
    
    // 토큰 가져오기
    final token = await getTokenFromStorage();
    if (token == null) {
      errorMessage.value = '로그인이 필요합니다.';
      return;
    }

    print('🔵 그룹 생성 API 호출: $url');
    print('🔵 그룹 데이터: ${jsonEncode(group.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(group.toJson()),
      );

      print('🟡 응답 상태: ${response.statusCode}');
      print('🟡 응답 내용: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final createdGroup = GroupResponse.fromJson(responseData);
        successMessage.value = '그룹 생성 성공: ${createdGroup.name}';
        print('✅ 그룹 생성 성공: ${createdGroup.name}');
      } else {
        // 에러 응답 파싱
        String errorMsg = '그룹 생성 실패';
        try {
          if (response.body.isNotEmpty) {
            // JSON 응답인 경우
            if (response.body.startsWith('{')) {
              final responseData = jsonDecode(response.body);
              errorMsg = responseData['message'] ?? errorMsg;
            } else {
              // 단순 텍스트 응답인 경우
              errorMsg = response.body;
            }
          }
        } catch (e) {
          print('🔥 에러 응답 파싱 실패: $e');
        }
        errorMessage.value = errorMsg;
        print('🔥 그룹 생성 실패: $errorMsg');
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류: $e';
      print('🔥 네트워크 오류: $e');
    }
  }
}
