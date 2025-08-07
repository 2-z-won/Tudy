import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Friend/model/AddListModel.dart';

class FriendAddListController extends GetxController {
  var requests = <FriendRequest>[].obs;
  var isLoading = false.obs;

  Future<void> fetchRequests(String userId) async {
    isLoading.value = true;
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/requests',
    ).replace(queryParameters: {'userId': userId});

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      requests.value = data
          .map((json) => FriendRequest.fromJson(json))
          .toList();
    } else {
      requests.clear();
    }
    isLoading.value = false;
  }

  Future<void> approveRequest(int requestId, String userId) async {
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/request/$requestId/accept',
    ).replace(queryParameters: {'userId': userId});
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        await fetchRequests(userId); // 목록 새로고침
      }
    }
  }

  Future<void> rejectRequest(int requestId, String userId) async {
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/request/$requestId/reject',
    ).replace(queryParameters: {'userId': userId});
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        await fetchRequests(userId); // 목록 새로고침
      }
    }
  }
}
