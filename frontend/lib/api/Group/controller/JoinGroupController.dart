import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Group/model/AddGroupModel.dart';
import 'package:frontend/constants/url.dart';

class JoinGroupController extends GetxController {
  var messageType = "".obs; // "success", "error"
  var message = "".obs;

  Future<int?> searchGroupIdByName(String groupName) async {
    final uri = Uri.parse('${Urls.apiUrl}groups/search?name=$groupName');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json["exists"] == true) {
        return json["groupId"]; // 백엔드에서 groupId도 내려준다고 가정
      } else {
        messageType.value = "error";
        message.value = "존재하지 않는 그룹입니다.";
        return null;
      }
    }
    return null;
  }

  Future<void> joinGroup({
    required int groupId,
    required String userId,
    required String password,
  }) async {
    final uri = Uri.parse('${Urls.apiUrl}groups/join');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "groupId": groupId,
        "userId": userId,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final messageResponse = jsonDecode(response.body);
      final msg = messageResponse["message"];
      if (msg.contains("완료")) {
        messageType.value = "success";
      } else {
        messageType.value = "error";
      }
      message.value = msg;
    }
  }
}
