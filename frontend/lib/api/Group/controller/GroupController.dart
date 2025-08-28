import 'dart:convert';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Group/model/GroupModel.dart';
import 'package:frontend/constants/url.dart';

class MyGroupController extends GetxController {
  final myGroups = <Group>[].obs;

  /// groupId -> goals
  final goalsByGroupId = <int, List<GroupGoal>>{}.obs;

  /// 기존 단일 조회가 필요하면 내부에서 이걸 호출해도 됨.
  Future<void> fetchMyGroups(String userId) async {
    final token = await getTokenFromStorage();
    if (token == null) {
      print("토큰이 없습니다.");
      return;
    }
    
    final uri = Uri.parse("${Urls.apiUrl}groups/user");
    print('🔵 그룹 목록 조회 API 호출: $uri');
    
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('🟡 그룹 조회 응답 상태: ${res.statusCode}');
    print('🟡 그룹 조회 응답 내용: ${res.body}');
    
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<dynamic> groupsData = data['groups'] ?? [];
      
      // null 값 필터링 및 안전한 파싱
      final List<Group> validGroups = [];
      for (int i = 0; i < groupsData.length; i++) {
        try {
          if (groupsData[i] != null) {
            final group = Group.fromJson(groupsData[i] as Map<String, dynamic>);
            validGroups.add(group);
            print('✅ 그룹 $i 파싱 성공: ${group.name}');
          } else {
            print('⚠️ 그룹 $i 는 null입니다. 건너뜁니다.');
          }
        } catch (e) {
          print('🔥 그룹 $i 파싱 실패: $e');
          print('🔥 그룹 $i 데이터: ${groupsData[i]}');
          continue; // 파싱 실패한 그룹은 건너뛰기
        }
      }
      
      myGroups.value = validGroups;
      print('✅ 그룹 목록 조회 성공: ${validGroups.length}개 유효한 그룹');
    } else {
      print("🔥 그룹 조회 실패: ${res.statusCode} - ${res.body}");
    }
  }

  /// ✅ 신규: 그룹 + 그룹목표를 한 번에 로드 (스크린샷 API)
  Future<void> fetchGroupsAndGoals(String userId) async {
    final token = await getTokenFromStorage();
    if (token == null) {
      throw Exception("토큰이 없습니다.");
    }
    
    final uri = Uri.parse("${Urls.apiUrl}groups/user");
    print('🔵 그룹&목표 조회 API 호출: $uri');
    
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🟡 그룹&목표 조회 응답 상태: ${res.statusCode}');
    print('🟡 그룹&목표 조회 응답 내용: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception("Failed to load groups & goals: ${res.statusCode}");
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    // groups - null 값 안전 처리
    final List<dynamic> groupsJson = json['groups'] ?? [];
    final List<Group> validGroups = [];
    for (int i = 0; i < groupsJson.length; i++) {
      try {
        if (groupsJson[i] != null) {
          final group = Group.fromJson(groupsJson[i] as Map<String, dynamic>);
          validGroups.add(group);
          print('✅ 그룹&목표: 그룹 $i 파싱 성공: ${group.name}');
        } else {
          print('⚠️ 그룹&목표: 그룹 $i 는 null입니다. 건너뜁니다.');
        }
      } catch (e) {
        print('🔥 그룹&목표: 그룹 $i 파싱 실패: $e');
        continue;
      }
    }
    myGroups.value = validGroups;

    // groupGoals - null 값 안전 처리
    final List<dynamic> goalsJson = json['groupGoals'] ?? [];
    final List<GroupGoal> validGoals = [];
    for (int i = 0; i < goalsJson.length; i++) {
      try {
        if (goalsJson[i] != null) {
          final goal = GroupGoal.fromJson(goalsJson[i] as Map<String, dynamic>);
          validGoals.add(goal);
          print('✅ 그룹&목표: 목표 $i 파싱 성공: ${goal.title}');
        } else {
          print('⚠️ 그룹&목표: 목표 $i 는 null입니다. 건너뜁니다.');
        }
      } catch (e) {
        print('🔥 그룹&목표: 목표 $i 파싱 실패: $e');
        continue;
      }
    }
    final goals = validGoals;

    final map = <int, List<GroupGoal>>{};
    for (final gg in goals) {
      map.putIfAbsent(gg.groupId, () => []).add(gg);
    }
    goalsByGroupId.value = map;
    
    print('✅ 그룹&목표 조회 성공: ${myGroups.length}개 그룹, ${goals.length}개 그룹 목표');
  }

  /// 편의 메서드: 비어있으면 로드
  Future<void> ensureLoaded(String userId) async {
    if (myGroups.isEmpty && goalsByGroupId.isEmpty) {
      await fetchGroupsAndGoals(userId);
    }
  }

  List<GroupGoal> goalsFor(int groupId) {
    return goalsByGroupId[groupId] ?? const [];
  }
}
