import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/constants/url.dart';

class CategoryController {
  /// 날짜별 카테고리별 목표 조회
  static Future<List<Goal>> fetchGoalsByDate({
    required String userId,
    required String date,
    String? categoryName,
  }) async {
    final queryParams = {
      'userId': userId,
      'date': date,
      if (categoryName != null) 'categoryName': categoryName,
    };

    final uri = Uri.parse(
      '${Urls.apiUrl}goals/by-date',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Goal.fromJson(item)).toList();
    } else {
      throw Exception('날짜별 목표 불러오기 실패: ${response.statusCode}');
    }
  }

  // 카테고리 목록 조회
  static Future<List<Category>> fetchCategories(String userId) async {
    final uri = Uri.parse(
      '${Urls.apiUrl}categories',
    ).replace(queryParameters: {'userId': userId});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('카테고리 목록 불러오기 실패: ${response.statusCode}');
    }
  }
}
