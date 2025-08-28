import 'package:get/get.dart';

/// 서버에 보낼 설치 대기 항목
class PendingInstall {
  final int spaceId; // 구매 카드 고유 id (서버에 보낼 값)
  final String spaceType; // 미리보기용
  final int level; // 미리보기용 (currentLevel)
  PendingInstall({
    required this.spaceId,
    required this.spaceType,
    required this.level,
  });
}

class RoomSelectionController extends GetxController {
  // 편집 모드 여부
  final isEditMode = false.obs;

  // 현재 선택된 “구매 카드”의 슬롯 id (설치 대상 선택)
  final selectedSlotId = RxnInt();
  void selectSlot(int? id) => selectedSlotId.value = id;

  /// 원본/스테이지 박스 이미지 (slotNumber -> imagePath)
  final originalBoxImages = <int, String?>{}.obs;
  final stagedBoxImages = <int, String?>{}.obs;

  /// 완료 시 서버에 보낼 설치 대기 목록 (slotNumber -> PendingInstall)
  final pendingInstalls = <int, PendingInstall>{}.obs;

  RoomSelectionController(int totalBoxes) {
    for (int i = 1; i <= totalBoxes; i++) {
      originalBoxImages[i] = null;
      stagedBoxImages[i] = null;
    }
  }

  // ===== 편집 모드 제어 =====
  void enterEditMode() {
    isEditMode.value = true;
    selectedSlotId.value = null;
  }

  void finishEditMode() {
    isEditMode.value = false;
    selectedSlotId.value = null;
  }

  void toggleEditMode() => isEditMode.toggle();

  // ===== 서버에서 받은 현재 설치 상태를 반영 =====
  // installed 예시: [{slotNumber: 3, spaceType: "LECTURE", level: 2}, ...]
  void loadFromServer({
    required int totalBoxes,
    required List<Map<String, dynamic>> installed,
  }) {
    // 초기화
    for (int i = 1; i <= totalBoxes; i++) {
      originalBoxImages[i] = null;
      stagedBoxImages[i] = null;
    }
    pendingInstalls.clear();

    // 반영
    for (final m in installed) {
      final sn = m['slotNumber'] as int;
      final st = m['spaceType'] as String;
      final lv = m['level'] as int;
      final img = 'assets/images/spaces/${st}_$lv.png';
      originalBoxImages[sn] = img;
      stagedBoxImages[sn] = img;
    }
  }

  // ===== 편집 중 로컬 미리보기(즉시 UI 반영) =====
  // 구매 카드(=slot entity)의 정보(id, spaceType, currentLevel)를 화면에서 넘겨줘야 함
  void stageInstall({
    required int slotNumber, // 박스 번호(1..N)
    required int spaceId, // 구매 카드 id (서버 전송용)
    required String spaceType, // 미리보기용
    required int level, // 미리보기용
  }) {
    if (!isEditMode.value) return;

    // 미리보기 이미지
    stagedBoxImages[slotNumber] = 'assets/images/spaces/${spaceType}_$level.png';

    // 서버 전송 대기 목록 갱신(덮어쓰기)
    pendingInstalls[slotNumber] = PendingInstall(
      spaceId: spaceId,
      spaceType: spaceType,
      level: level,
    );
  }

  /// 스테이지 내역을 원본으로 커밋(서버 반영 성공 후 호출)
  void commitLocal() {
    for (final k in originalBoxImages.keys) {
      originalBoxImages[k] = stagedBoxImages[k];
    }
    pendingInstalls.clear();
    isEditMode.value = false;
    selectedSlotId.value = null;
  }

  /// 스테이지 롤백(편집 취소)
  void cancelEdit() {
    for (final k in stagedBoxImages.keys) {
      stagedBoxImages[k] = originalBoxImages[k];
    }
    pendingInstalls.clear();
    isEditMode.value = false;
    selectedSlotId.value = null;
  }
}
