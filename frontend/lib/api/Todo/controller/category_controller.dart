import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/constants/url.dart';
import 'package:get/get.dart';

class CategoryController {
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

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

    print('🔵 요청 URI: $uri');

    final response = await http.get(uri);

    print('🟡 응답 statusCode: ${response.statusCode}');
    print('🟡 응답 body: ${response.body}');

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

    print("uri: $uri");

    final response = await http.get(uri);
    print("status: ${response.statusCode}");
    print("body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('카테고리 목록 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> addCategory({
    required String userId,
    required String name,
    required int colorIndex, // 1~10
    required String categoryType,
    required  String selectedEmoji,
  }) async {
    errorMessage.value = '';
    successMessage.value = '';

    if (name.trim().isEmpty) {
      errorMessage.value = "카테고리명을 입력해주세요.";
      return;
    }

    final request = AddCategory(
      userId: userId,
      name: name.trim(),
      color: colorIndex,
      categoryType: categoryType,
      icon : selectedEmoji,
    );

    try {
      final body = jsonEncode(request.toJson());
      print("📤 카테고리 생성 요청 → $body");

      final response = await http.post(
        Uri.parse('${Urls.apiUrl}categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print("📥 응답 → ${response.statusCode}");
      print("📥 응답 바디 → ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("카테고리 생성");
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? "카테고리 생성 실패";
      }
    } catch (e) {
      errorMessage.value = "서버 오류: $e";
    }
  }
}
