import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Group/model/GroupAddListController.dart';

class GroupAddListController extends GetxController {
  var requests = <GroupRequest>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchGroupRequests({
    required int groupId,
    required String ownerId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    final uri = Uri.parse(
      "${Urls.apiUrl}groups/$groupId/pending-requests?ownerId=$ownerId",
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        requests.value = data.map((e) => GroupRequest.fromJson(e)).toList();
      } else {
        errorMessage.value = '신청 목록을 불러오지 못했습니다.';
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류 발생: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRequest(int requestId, String ownerId) async {
    final uri = Uri.parse(
      "${Urls.apiUrl}groups/$requestId/approve?ownerId=$ownerId",
    );
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      requests.removeWhere((r) => r.id == requestId);
    }
  }

  Future<void> rejectRequest(int requestId, String ownerId) async {
    final uri = Uri.parse(
      "${Urls.apiUrl}groups/$requestId/reject?ownerId=$ownerId",
    );
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      requests.removeWhere((r) => r.id == requestId);
    }
  }
}
