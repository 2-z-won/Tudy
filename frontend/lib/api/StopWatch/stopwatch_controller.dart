import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';

class StudySessionController extends GetxController {
  final accumulatedTime = Duration.zero.obs;

  Future<void> fetchAccumulatedTime(int goalId) async {
    final uri = Uri.parse('${Urls.apiUrl}sessions/goal/$goalId/duration');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hours = data['hours'] ?? 0;
        final minutes = data['minutes'] ?? 0;
        accumulatedTime.value = Duration(hours: hours, minutes: minutes);
      } else {
        print('❌ 누적 시간 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 누적 시간 요청 에러: $e');
    }
  }

  Future<void> logStudyTime({
    required String userId,
    required int goalId,
    required int seconds,
  }) async {
    final uri = Uri.parse('${Urls.apiUrl}sessions/log');

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    final body = {
      "userId": userId,
      "goalId": goalId,
      "hours": hours,
      "minutes": minutes,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ 학습 시간 기록 완료');
        await fetchAccumulatedTime(goalId); // 기록 후 새로고침
      } else {
        print('❌ 학습 시간 기록 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 학습 시간 기록 에러: $e');
    }
  }
}
