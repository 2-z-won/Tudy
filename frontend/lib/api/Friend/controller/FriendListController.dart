import 'dart:convert';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/Friend/model/FriendListModel.dart';

class FriendListController extends GetxController {
  // 친구 리스트
  final friendList = <Friend>[].obs;

  // 친구이름 -> 그 친구와 함께하는 목표 리스트
  final goalsByFriendName = <String, List<FriendGoal>>{}.obs;

  // 전체 친구/목표 한번에 가져오기 (백엔드 응답 구조에 맞춤)
  Future<void> fetchFriendsAndGoals(String userId) async {
    try {
      final token = await getTokenFromStorage();
      final uri = Uri.parse('${Urls.apiUrl}friends/$userId'); // ← 스샷 API 경로
      
      print('🔍 친구 목록 API 호출: $uri');
      print('🔍 토큰: ${token?.substring(0, 20)}...');
      
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🟡 친구 목록 응답 상태: ${res.statusCode}');
      print('🟡 친구 목록 응답 내용: ${res.body}');

      if (res.statusCode != 200) {
        print('🔥 친구 목록 조회 실패: ${res.statusCode}');
        throw Exception('Failed to load friends & goals: ${res.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(res.body);

      // 1) 친구 목록 - null 체크 추가
      final List<dynamic> friendsJson = data['friends'] ?? [];
      print('🔍 파싱할 친구 데이터: $friendsJson');
      
      if (friendsJson.isNotEmpty) {
        friendList.value = friendsJson.map((j) {
          if (j == null) {
            print('🔥 null 친구 데이터 건너뛰기');
            return null;
          }
          try {
            return Friend.fromJson(j as Map<String, dynamic>);
          } catch (e) {
            print('🔥 친구 데이터 파싱 실패: $e, 데이터: $j');
            return null;
          }
        }).whereType<Friend>().toList();
      } else {
        friendList.value = [];
      }

      // 2) 친구 목표 - null 체크 추가
      final List<dynamic> goalsJson = data['friendGoals'] ?? [];
      print('🔍 파싱할 목표 데이터: $goalsJson');
      
      if (goalsJson.isNotEmpty) {
        final allGoals = goalsJson.map((j) {
          if (j == null) {
            print('🔥 null 목표 데이터 건너뛰기');
            return null;
          }
          try {
            return FriendGoal.fromJson(j as Map<String, dynamic>);
          } catch (e) {
            print('🔥 목표 데이터 파싱 실패: $e, 데이터: $j');
            return null;
          }
        }).whereType<FriendGoal>().toList();

        // 3) 이름별로 그룹핑
        final map = <String, List<FriendGoal>>{};
        for (final g in allGoals) {
          if (g.friendName != null) {
            map.putIfAbsent(g.friendName, () => []).add(g);
          }
        }
        goalsByFriendName.value = map;
      } else {
        goalsByFriendName.value = {};
      }
      
      print('✅ 친구 목록 조회 성공: ${friendList.length}명, 목표: ${goalsByFriendName.length}개');
      
    } catch (e, stackTrace) {
      print('🔥 친구 목록 조회 중 에러: $e');
      print('🔥 Stack trace: $stackTrace');
      
      // 에러 발생 시 빈 리스트로 초기화
      friendList.value = [];
      goalsByFriendName.value = {};
    }
  }

  // 특정 친구이름의 목표 꺼내기
  List<FriendGoal> goalsFor(String friendName) {
    return goalsByFriendName[friendName] ?? const [];
  }
}
