import 'package:frontend/utils/auth_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/constants/url.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  /// 날짜별 카테고리별 목표 조회
  Future<List<Goal>> fetchGoalsByDate({
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

    final token = await getTokenFromStorage();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // GET은 Accept만으로 충분
      },
    );

    print('🟡 응답 statusCode: ${response.statusCode}');
    print('🟡 응답 body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print('🔍 파싱할 목표 개수: ${data.length}');
      
      final List<Goal> goals = [];
      for (int i = 0; i < data.length; i++) {
        try {
          print('🔍 목표 $i 파싱 시도...');
          final goal = Goal.fromJson(data[i]);
          goals.add(goal);
          print('✅ 목표 $i 파싱 성공: ${goal.title}');
        } catch (e) {
          print('🔥 목표 $i 파싱 실패: $e');
          print('🔥 목표 $i 데이터: ${data[i]}');
          // 파싱 실패한 목표는 건너뛰고 계속 진행
          continue;
        }
      }
      
      return goals;
    } else {
      throw Exception('날짜별 목표 불러오기 실패: ${response.statusCode}');
    }
  }

  // 카테고리 목록 조회
  Future<List<Category>> fetchCategories(String userId) async {
    try {
      print("🔍 fetchCategories 시작 - userId: $userId");
      
      final uri = Uri.parse(
        '${Urls.apiUrl}categories',
      ).replace(queryParameters: {'userId': userId});
      print("🔍 URI 생성 완료: $uri");

      print("🔍 토큰 가져오기 시작...");
      final token = await getTokenFromStorage();
      print("📤 토큰 확인: $token");
      print("📤 요청 URL: $uri");
      
      print("🔍 HTTP 요청 시작...");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // GET은 Accept만으로 충분
        },
      );
      print("🔍 HTTP 요청 완료");

      print("📥 응답 status: ${response.statusCode}");
      print("📥 응답 body: ${response.body}");

      if (response.statusCode == 200) {
        print("🔍 JSON 파싱 시작...");
        final List data = json.decode(response.body);
        print("🔍 카테고리 객체 변환 시작...");
        final result = data.map((item) => Category.fromJson(item)).toList();
        print("🔍 fetchCategories 완료 - ${result.length}개 카테고리");
        return result;
      } else {
        throw Exception('카테고리 목록 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("🔍 fetchCategories 중 에러 발생: $e");
      print("🔍 에러 타입: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<void> addCategory({
    required String userId,
    required String name,
    required int colorIndex, // 1~10
    required String categoryType,
    required String selectedEmoji,
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
      icon: selectedEmoji,
    );

    try {
      final body = jsonEncode(request.toJson());
      print("📤 카테고리 생성 요청 → $body");

      final token = await getTokenFromStorage();
              final response = await http.post(
          Uri.parse('${Urls.apiUrl}categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
