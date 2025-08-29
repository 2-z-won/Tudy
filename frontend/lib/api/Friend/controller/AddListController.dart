import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Friend/model/AddListModel.dart';
import 'package:frontend/utils/auth_util.dart';

class FriendAddListController extends GetxController {
  var requests = <FriendRequest>[].obs;
  var isLoading = false.obs;

  Future<void> fetchRequests(String userId) async {
    isLoading.value = true;
    final token = await getTokenFromStorage();
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/requests',
    ).replace(queryParameters: {'userId': userId});

    print('🔍 친구 신청 목록 API 호출: $uri');
    print('🔍 토큰: ${token?.substring(0, 20)}...');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('🟡 친구 신청 목록 응답 상태: ${response.statusCode}');
      print('🟡 친구 신청 목록 응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🔍 파싱된 데이터 개수: ${data.length}');
        
        requests.value = data
            .map((json) => FriendRequest.fromJson(json))
            .toList();
        print('✅ 친구 신청 목록 조회 성공: ${requests.length}개');
      } else {
        print('🔥 친구 신청 목록 조회 실패: ${response.statusCode}');
        requests.clear();
      }
    } catch (e) {
      print('🔥 친구 신청 목록 조회 중 에러: $e');
      requests.clear();
    }
    
    isLoading.value = false;
  }

  Future<void> approveRequest(int requestId, String userId) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/request/$requestId/accept',
    ).replace(queryParameters: {'userId': userId});
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        await fetchRequests(userId); // 목록 새로고침
      }
    }
  }

  Future<void> rejectRequest(int requestId, String userId) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse(
      '${Urls.apiUrl}friends/request/$requestId/reject',
    ).replace(queryParameters: {'userId': userId});
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        await fetchRequests(userId); // 목록 새로고침
      }
    }
  }
}
