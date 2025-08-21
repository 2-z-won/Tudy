import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/constants/url.dart';
import 'package:get/get.dart';

class GoalController {
  static Future<List<Goal>> fetchGoals(String userId) async {
    final uri = Uri.parse('${Urls.apiUrl}goals?userId=$userId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((jsonItem) => Goal.fromJson(jsonItem)).toList();
    } else {
      throw Exception('목표 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<void> addGoal(AddGoal goalRequest) async {
    errorMessage.value = '';
    successMessage.value = '';

    try {
      print('📤 목표 생성 요청 데이터: ${jsonEncode(goalRequest.toJson())}');

      final response = await http.post(
        Uri.parse('${Urls.apiUrl}goals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(goalRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = "목표가 성공적으로 등록되었습니다.";
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? "목표 등록 실패";
      }
    } catch (e) {
      errorMessage.value = "서버 오류: $e";
    }
  }

  // CategoryController.dart
  static Future<int?> fetchGoalDurationSeconds(int goalId) async {
    // GET /api/sessions/goal/{goalId}/duration  -> { "hours": 10, "minutes": 45 }
    final uri = Uri.parse('${Urls.apiUrl}sessions/goal/$goalId/duration');
    final res = await http.get(uri);

    print('⏱️ duration[$goalId] status=${res.statusCode} body=${res.body}');
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      final int hours = (data['hours'] ?? 0) as int;
      final int minutes = (data['minutes'] ?? 0) as int;
      return hours * 3600 + minutes * 60; // 초 단위 반환
    } else {
      // 실패하면 null 반환(진행률 0%로 보이게)
      return null;
    }
  }

  static Future<bool> deleteGoal(int goalId) async {
    final uri = Uri.parse('${Urls.apiUrl}goals/$goalId');
    final res = await http.delete(uri);
    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
