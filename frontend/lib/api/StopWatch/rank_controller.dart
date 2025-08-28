// lib/pages/MainPage/api/session/study_ranking_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class RankItem {
  final String major;
  final int value;
  RankItem({required this.major, required this.value});
}

class StudyRankingController extends GetxController {
  final items = <RankItem>[].obs;
  final error = ''.obs;

  final _idx = 0.obs;
  Timer? _ticker;

  RankItem? get current =>
      items.isEmpty ? null : items[_idx.value % items.length];

  int get currentRank => items.isEmpty ? 0 : (_idx.value % items.length) + 1;

  void startTicker({Duration interval = const Duration(seconds: 1)}) {
    stopTicker();
    _ticker = Timer.periodic(interval, (_) {
      if (items.isEmpty) return;
      _idx.value = (_idx.value + 1) % items.length;
    });
  }

  void stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> fetchAndStart() async {
    await fetchRanking();
    _idx.value = 0;
    startTicker();
  }

  Future<void> fetchRanking() async {
    error.value = '';
    try {
      final userId = await getUserIdFromStorage();
      final token = await getTokenFromStorage();
      final uri = Uri.parse('${Urls.apiUrl}sessions/ranking');
      if (userId == null || token == null) throw 'Not logged in';

      print('[RANK] 요청 → $uri');
      print('[RANK] userId=$userId token=$token');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // GET은 Accept만으로 충분
        },
      );

      print('[RANK] status=${res.statusCode}');
      print('[RANK] body=${res.body}');
      if (res.statusCode < 200 || res.statusCode >= 300) {
        error.value = '랭킹 조회 실패 [${res.statusCode}]';
        items.clear();
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map) {
        final list =
            decoded.entries
                .map(
                  (e) => RankItem(
                    major: e.key.toString(),
                    value: (e.value as num).toInt(),
                  ),
                )
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value)); // 점수 높은 순으로 정렬
        items.assignAll(list);
      } else {
        error.value = '응답이 Map 형식이 아님';
      }
    } catch (e) {
      error.value = '랭킹 조회 오류: $e';
      items.clear();
    }
  }

  @override
  void onClose() {
    stopTicker();
    super.onClose();
  }
}
