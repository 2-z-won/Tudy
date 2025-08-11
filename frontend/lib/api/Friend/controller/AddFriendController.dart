import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';

class FriendAddRequestController {
  static var errorMessage = ''.obs;
  static var successMessage = ''.obs;
  static Future<void> sendFriendRequest({
    required String userId,
    required String toUserId,
  }) async {
    final uri = Uri.parse(
      "${Urls.apiUrl}friends/request",
    ).replace(queryParameters: {'userId': userId, 'toUserId': toUserId});

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        successMessage.value = "친구 요청이 전송되었습니다.";
        errorMessage.value = '';
      } else {
        errorMessage.value = "친구 요청에 실패했습니다.";
        successMessage.value = '';
      }
    } else {
      errorMessage.value = "서버 오류가 발생했습니다.";
      successMessage.value = '';
    }
  }
}
