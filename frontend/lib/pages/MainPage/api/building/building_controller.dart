// lib/pages/MainPage/api/building/building_controller.dart
import 'dart:convert';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart'
    show BuildingType;
import 'package:frontend/pages/MainPage/api/building/building_model.dart';

class BuildingController extends GetxController {
  // 상태
  //final isLoading = false.obs;
  final error = ''.obs;

  /// 건물별 응답을 저장 (department/library/gym/cafe)
  /// 필요할 때 꺼내 쓰면 됨: infos[BuildingType.cafe]
  final infos = <BuildingType, BuildingInfo>{}.obs;

  /// 단일 건물 조회
  Future<void> fetchBuilding(BuildingType type) async {
    // ❌ error.value = '';  ← 지워요
    try {
      final userId = await getUserIdFromStorage();
      final token = await getTokenFromStorage();
      if (userId == null || token == null) throw 'Not logged in';

      final uri = Uri.parse(
        '${Urls.apiUrl}users/$userId/buildings/${type.name}',
      );
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // GET은 Accept만으로 충분
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
         print('🏢 건물 조회 성공 (${type.name}): ${res.body}');
        final Map<String, dynamic> json = jsonDecode(res.body);
        infos[type] = BuildingInfo.fromJson(json);
        infos.refresh(); // 응답 이후에만 Rx 변경 👍
      } else {
        error.value = '건물 조회 실패 [${res.statusCode}] ${res.body}';
      }
    } catch (e) {
      error.value = '건물 조회 오류: $e';
    }
  }

  /// 모든 건물 일괄 조회 (필요할 때만 호출)
  Future<void> fetchAll() async {
    // ❌ error.value = '';  ← 지워요
    try {
      await Future.wait([
        fetchBuilding(BuildingType.DEPARTMENT),
        fetchBuilding(BuildingType.LIBRARY),
        fetchBuilding(BuildingType.GYM),
        fetchBuilding(BuildingType.CAFE),
      ]);
      // 여기선 추가 작업 불필요 (각 fetchBuilding에서 infos 갱신함)
    } catch (_) {
      // 개별 fetch에서 error 세팅하므로 여기선 생략 가능
    }
  }

  /// 외관 업그레이드 단계 (API는 true/false만 주므로 1 or 2로 변환해서 쓰고 싶을 때)
  int exteriorLevelOf(BuildingType type) {
    final info = infos[type];
    if (info == null) return 1;
    return info.building.exteriorUpgraded ? 2 : 1;
  }

  Future<bool> purchaseSpace({
    required BuildingType buildingType,
    required String spaceType,
  }) async {
    try {
      final userId = await getUserIdFromStorage();
      final token = await getTokenFromStorage();
      if (userId == null || token == null) throw 'Not logged in';

      final uri = Uri.parse(
        '${Urls.apiUrl}users/$userId/buildings/${buildingType.name}/purchase',
      );
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"spaceType": spaceType}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // ✅ 다시 조회해서 카드/슬롯 상태 갱신
        await fetchBuilding(buildingType);
        return true;
      } else {
        error.value = '구매 실패 [${res.statusCode}] ${res.body}';
        return false;
      }
    } catch (e) {
      error.value = '구매 오류: $e';
      return false;
    }
  }

  Future<bool> installMany({
    required BuildingType buildingType,
    required Map<int, PendingInstall> items, // slotNumber -> PendingInstall
  }) async {
    if (items.isEmpty) return true;

    try {
      final userId = await getUserIdFromStorage();
      final token = await getTokenFromStorage();
      if (userId == null || token == null) throw 'Not logged in';

      for (final entry in items.entries) {
        final slotNumber = entry.key;
        final pending = entry.value;

        final uri = Uri.parse(
          '${Urls.apiUrl}users/$userId/buildings/${buildingType.name}/slots/$slotNumber/install',
        );

        final res = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"spaceId": pending.spaceId}), // ✅ 서버 요구사항: spaceId
        );

        if (res.statusCode < 200 || res.statusCode >= 300) {
          error.value =
              '설치 실패(slot $slotNumber) [${res.statusCode}] ${res.body}';
          return false;
        }
      }
      return true;
    } catch (e) {
      error.value = '설치 오류: $e';
      return false;
    }
  }
}
