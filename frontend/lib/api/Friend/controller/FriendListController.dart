import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Friend/model/FriendListModel.dart';

class FriendListController extends GetxController {
  var friendList = <Friend>[].obs;

  Future<void> fetchFriends(String userId) async {
    final uri = Uri.parse('${Urls.apiUrl}friends?userId=$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      friendList.value = data.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }
}
