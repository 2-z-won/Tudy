import 'dart:convert';
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
    final uri = Uri.parse('${Urls.apiUrl}friends/$userId'); // ← 스샷 API 경로
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load friends & goals: ${res.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);

    // 1) 친구 목록
    final List<dynamic> friendsJson = data['friends'] ?? [];
    friendList.value = friendsJson.map((j) => Friend.fromJson(j)).toList();

    // 2) 친구 목표
    final List<dynamic> goalsJson = data['friendGoals'] ?? [];
    final allGoals = goalsJson.map((j) => FriendGoal.fromJson(j)).toList();

    // 3) 이름별로 그룹핑
    final map = <String, List<FriendGoal>>{};
    for (final g in allGoals) {
      map.putIfAbsent(g.friendName, () => []).add(g);
    }
    goalsByFriendName.value = map;
  }

  // 특정 친구이름의 목표 꺼내기
  List<FriendGoal> goalsFor(String friendName) {
    return goalsByFriendName[friendName] ?? const [];
  }
}
