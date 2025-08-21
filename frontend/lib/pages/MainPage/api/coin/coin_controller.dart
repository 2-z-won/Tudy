// lib/pages/MainPage/api/coin/coins_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';
import 'coin_model.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart'
    show BuildingType;

class CoinsController extends GetxController {
  final coins = <Coin>[].obs;
  final selectedType = ''.obs; // 서버 coinType 그대로
  final isLoading = false.obs;
  final error = ''.obs;

  late final NumberFormat _fmt;

  @override
  void onInit() {
    super.onInit();
    _fmt = NumberFormat.decimalPattern('ko_KR'); // 1,000 형식
    // fetchCoins()
    //     .then((list) => coins.assignAll(list))
    //     .catchError((e) => error.value = '코인 조회 실패: $e');
  }

  /// 건물 타입 -> 코인 타입 매핑
  String coinTypeOf(BuildingType b) {
    switch (b) {
      case BuildingType.DEPARTMENT:
      case BuildingType.LIBRARY:
        return 'ACADEMIC_SAEDO';
      case BuildingType.GYM:
        return 'GYM';
      case BuildingType.CAFE:
        return 'CAFE';
    }
  }

  Future<List<Coin>> fetchCoins() async {
    error.value = '';
    try {
      final uri = Uri.parse('${Urls.apiUrl}coins');
      final token = await getTokenFromStorage();
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final list = data.map((json) => Coin.fromJson(json)).toList();
        coins.assignAll(list); // ✅ 바로 반영 (드롭다운이 즉시 그림)
        return list;
      } else {
        error.value = '코인 불러오기 실패: ${res.statusCode}';
        return const [];
      }
    } catch (e) {
      error.value = '코인 조회 중 오류: $e';
      return const [];
    } finally {
      isLoading.value = false; // ✅ 종료
    }
  }

  /// 단일 타입 조회: GET /api/coins/{coinType}
  Future<void> fetchOne(String coinType) async {
    isLoading.value = true;
    error.value = '';
    try {
      final token = await getTokenFromStorage();
      if (token == null) throw 'Not logged in';

      final uri = Uri.parse('${Urls.apiUrl}coins/$coinType');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final updated = Coin.fromJson(data);

        // coins 리스트에 머지(있으면 교체, 없으면 추가)
        final i = coins.indexWhere((c) => c.coinType == updated.coinType);
        if (i >= 0) {
          coins[i] = updated;
          coins.refresh();
        } else {
          coins.add(updated);
        }
      } else {
        error.value = '코인 단일 조회 실패 [${res.statusCode}] ${res.body}';
      }
    } catch (e) {
      error.value = '코인 단일 조회 중 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 화면 전환 시, 현재 건물에 맞는 타입을 선택해두기
  void ensureSelectedForBuilding(BuildingType b) {
    final t = coinTypeOf(b);
    selectedType.value = t;
  }

  /// 구매/설치 등 액션 이후 최신화(해당 타입만 빠르게)
  Future<void> refreshAfterAction(BuildingType b) async {
    await fetchOne(coinTypeOf(b));
  }

  // ----- 표시 유틸 -----
  int amountOf(String type) =>
      coins.firstWhereOrNull((c) => c.coinType == type)?.amount ?? 0;

  String amountTextOf(String type) => _fmt.format(amountOf(type));

  String imagePathOf(String type) => 'images/coin/$type.png'; // 에셋 경로

  List<String> get otherTypes => coins
      .map((c) => c.coinType)
      .where((t) => t != selectedType.value)
      .toList();

  void select(String type) => selectedType.value = type;
}
