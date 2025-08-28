import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Group/model/GroupAddListController.dart';
import 'package:frontend/utils/auth_util.dart';

class GroupAddListController extends GetxController {
  var requests = <GroupRequest>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchGroupRequests({
    required int groupId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final token = await getTokenFromStorage();
    final uri = Uri.parse("${Urls.apiUrl}groups/$groupId/pending-requests");
    
    print('🔍 그룹 신청 목록 API 호출: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('🟡 그룹 신청 목록 응답 상태: ${response.statusCode}');
      print('🟡 그룹 신청 목록 응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<GroupRequest> validRequests = [];
        
        for (int i = 0; i < data.length; i++) {
          try {
            print('🔍 신청 $i 파싱 시도...');
            final request = GroupRequest.fromJson(data[i] as Map<String, dynamic>);
            validRequests.add(request);
            print('✅ 신청 $i 파싱 성공: ${request.fromUser?['name'] ?? 'Unknown User'}');
          } catch (e) {
            print('🔥 신청 $i 파싱 실패: $e');
            print('🔥 신청 $i 데이터: ${data[i]}');
            continue; // 파싱 실패한 신청은 건너뛰기
          }
        }
        
        requests.value = validRequests;
        print('✅ 그룹 신청 목록 조회 성공: ${validRequests.length}개 유효한 신청');
      } else {
        errorMessage.value = '신청 목록을 불러오지 못했습니다: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류 발생: $e';
      print('🔥 그룹 신청 목록 조회 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveRequest(int requestId) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse("${Urls.apiUrl}groups/$requestId/approve");
    
    print('🔍 그룹 신청 승인 API 호출: $uri');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🟡 그룹 신청 승인 응답 상태: ${response.statusCode}');
    print('🟡 그룹 신청 승인 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      requests.removeWhere((r) => r.id == requestId);
      print('✅ 그룹 신청 승인 성공');
      return true;
    } else {
      errorMessage.value = '신청 승인 실패: ${response.statusCode}';
      print('🔥 그룹 신청 승인 실패: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> rejectRequest(int requestId) async {
    final token = await getTokenFromStorage();
    final uri = Uri.parse("${Urls.apiUrl}groups/$requestId/reject");
    
    print('🔍 그룹 신청 거부 API 호출: $uri');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🟡 그룹 신청 거부 응답 상태: ${response.statusCode}');
    print('🟡 그룹 신청 거부 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      requests.removeWhere((r) => r.id == requestId);
      print('✅ 그룹 신청 거부 성공');
      return true;
    } else {
      errorMessage.value = '신청 거부 실패: ${response.statusCode}';
      print('🔥 그룹 신청 거부 실패: ${response.statusCode}');
      return false;
    }
  }
}
