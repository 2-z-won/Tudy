import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Group/model/AddGroupModel.dart';
import 'package:frontend/constants/url.dart';

class GroupController extends GetxController {
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<void> createGroup(AddGroup group) async {
    final url = Uri.parse('${Urls.apiUrl}groups');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(group.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final createdGroup = GroupResponse.fromJson(responseData);
        successMessage.value = '그룹 생성 성공: ${createdGroup.name}';
      } else {
        final responseData = jsonDecode(response.body);
        errorMessage.value = responseData['message'] ?? '그룹 생성 실패';
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류: $e';
    }
  }
}
