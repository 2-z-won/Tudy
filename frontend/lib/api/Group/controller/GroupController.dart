import 'dart:convert';
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
    final uri = Uri.parse("${Urls.apiUrl}user/$userId/groups");
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      myGroups.value = data.map((g) => Group.fromJson(g)).toList();
    } else {
      print("그룹 조회 실패: ${res.statusCode}");
    }
  }

  /// ✅ 신규: 그룹 + 그룹목표를 한 번에 로드 (스크린샷 API)
  Future<void> fetchGroupsAndGoals(String userId) async {
    final uri = Uri.parse("${Urls.apiUrl}groups/user/$userId");
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load groups & goals: ${res.statusCode}");
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    // groups
    final List<dynamic> groupsJson = json['groups'] ?? [];
    myGroups.value = groupsJson.map((g) => Group.fromJson(g)).toList();

    // groupGoals
    final List<dynamic> goalsJson = json['groupGoals'] ?? [];
    final goals = goalsJson.map((g) => GroupGoal.fromJson(g)).toList();

    final map = <int, List<GroupGoal>>{};
    for (final gg in goals) {
      map.putIfAbsent(gg.groupId, () => []).add(gg);
    }
    goalsByGroupId.value = map;
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
