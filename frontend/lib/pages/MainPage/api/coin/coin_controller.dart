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
  final selectedType = ''.obs;
  final error = ''.obs;

  // 고정 노출 순서
  static const List<String> _order = ['ACADEMIC_SAEDO', 'CAFE', 'GYM'];

  final NumberFormat _fmt = NumberFormat.decimalPattern('ko_KR');

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

  // 리스트에 upsert 하면서 고정 순서 유지
  void _upsertAndSort(Coin updated) {
    final i = coins.indexWhere((c) => c.coinType == updated.coinType);
    if (i >= 0) {
      coins[i] = updated;
    } else {
      coins.add(updated);
    }
    // 고정 순서대로 정렬
    coins.sort(
      (a, b) =>
          _order.indexOf(a.coinType).compareTo(_order.indexOf(b.coinType)),
    );
    coins.refresh();
  }

  Future<void> fetchOne(String coinType) async {
    try {
      final token = await getTokenFromStorage();
      if (token == null) throw 'Not logged in';

      final uri = Uri.parse('${Urls.apiUrl}coins/$coinType');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('🪙 GET $uri');
      print('📥 status: ${res.statusCode}');
      print('📦 body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // 예: {"balance":1000}
        final balance = jsonDecode(res.body) as int;
        final updated = Coin(coinType: coinType, amount: balance);
        _upsertAndSort(updated);

        // 선택 타입이 비어있으면 기본을 세팅
        if (selectedType.value.isEmpty) {
          selectedType.value = coinTypeOf(BuildingType.DEPARTMENT); // 기본 새도
        }
      } else {
        error.value = '코인 단일 조회 실패 [${res.statusCode}] ${res.body}';
      }
    } catch (e) {
      error.value = '코인 단일 조회 중 오류: $e';
    }
  }

  // 세 가지 타입을 병렬로 조회 (표시는 ACADEMIC → CAFE → GYM 고정)
  Future<void> fetchAllTypes() async {
    try {
      await Future.wait([
        fetchOne('ACADEMIC_SAEDO'),
        fetchOne('CAFE'),
        fetchOne('GYM'),
      ]);
      if (selectedType.value.isEmpty) {
        selectedType.value = 'ACADEMIC_SAEDO';
      }
    } catch (_) {
      // 개별 fetchOne에서 error를 채우므로 별도 처리 불필요
    }
  }

  /// 화면 전환 시, 현재 건물에 맞는 타입을 선택해두기
  void ensureSelectedForBuilding(BuildingType b) {
    selectedType.value = coinTypeOf(b);
  }

  /// 구매/설치 등 액션 이후 최신화(해당 타입만 빠르게)
  Future<void> refreshAfterAction(BuildingType b) async {
    await fetchOne(coinTypeOf(b));
  }

  int amountOf(String type) =>
      coins.firstWhereOrNull((c) => c.coinType == type)?.amount ?? 0;

  String amountTextOf(String type) => _fmt.format(amountOf(type));

  String imagePathOf(String type) => 'images/coin/$type.png';

  List<String> get otherTypes => coins
      .map((c) => c.coinType)
      .where((t) => t != selectedType.value)
      .toList();

  void select(String type) => selectedType.value = type;
}
