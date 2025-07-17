import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/constants/url.dart'; // ✅ 추가

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
}
