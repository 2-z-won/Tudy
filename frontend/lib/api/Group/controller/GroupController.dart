import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:frontend/api/Group/model/GroupModel.dart';
import 'package:frontend/constants/url.dart';

class MyGroupController extends GetxController {
  var myGroups = <Group>[].obs;

  Future<void> fetchMyGroups(String userId) async {
    final uri = Uri.parse("${Urls.apiUrl}user/$userId/groups");
    print(uri);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        myGroups.value = data.map((g) => Group.fromJson(g)).toList();
      } else {
        print("그룹 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }
  }
}
