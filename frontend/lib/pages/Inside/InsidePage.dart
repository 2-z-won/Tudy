import 'package:flutter/material.dart';
import 'package:frontend/pages/Inside/CardSelector.dart';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';
import 'package:frontend/pages/MainPage/api/building/building_controller.dart';
import 'package:frontend/pages/MainPage/api/building/building_model.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class InsidePageView extends StatefulWidget {
  const InsidePageView({super.key});
  @override
  State<InsidePageView> createState() => _InsidePageViewState();
}

class _InsidePageViewState extends State<InsidePageView> {
  late final RoomSelectionController controller;
  late final BuildingController buildingCtrl;
  late final CoinsController coinsCtrl;

  late final BuildingType building;
  late BuildingInfo info;
  late int floors, totalSlots;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map? ?? {};
    building = args['building'] as BuildingType;
    info     = args['info'] as BuildingInfo;

    floors     = info.config.floors;
    totalSlots = floors * 2;

    // GetX 컨트롤러들이 등록되어 있는지 확인하고 가져오기
    try {
      buildingCtrl = Get.find<BuildingController>();
    } catch (e) {
      print('🔥 BuildingController를 찾을 수 없습니다: $e');
      buildingCtrl = Get.put(BuildingController());
    }
    
    try {
      coinsCtrl = Get.find<CoinsController>();
    } catch (e) {
      print('🔥 CoinsController를 찾을 수 없습니다: $e');
      coinsCtrl = Get.put(CoinsController());
    }
    coinsCtrl.ensureSelectedForBuilding(building); // 읽기 전용 보장

    // ① 컨트롤러 동기 생성 (빌드 전에 보장)
    // 기존 컨트롤러가 있다면 삭제 후 새로 생성
    try {
      Get.delete<RoomSelectionController>();
    } catch (e) {
      // 컨트롤러가 없으면 무시
    }
    controller = Get.put(RoomSelectionController(totalSlots));

    // ② 비동기 초기화 시작 (await는 여기서 안 함)
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 로그인/유저 준비
      final uid = await getUserIdFromStorage();
      if (!mounted) return;        // 페이지 떠났으면 중단
      if (uid == null) {
        debugPrint('❌ 저장된 사용자 ID가 없습니다.');
        return;
      }

      // ③ 준비되었을 때만 서버 상태 반영 (이 시점은 build() 바깥)
      await controller.loadFromServer(
        totalBoxes: totalSlots,
        installed: info.slots
            .where((s) => s.slotNumber != null)
            .map((s) => {
                  'slotNumber': s.slotNumber!,
                  'spaceType' : s.spaceType,
                  'level'     : s.currentLevel,
                })
            .toList(),
      );
      
      print('✅ InsidePage 초기화 완료');
    } catch (e, stackTrace) {
      print('🔥 InsidePage 초기화 중 에러 발생: $e');
      print('🔥 Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<RoomSelectionController>()) {
      Get.delete<RoomSelectionController>();
    }
    super.dispose();
  }


  Future<void> refreshFromServer() async {
    await buildingCtrl.fetchBuilding(building);
    final latestInfo = buildingCtrl.infos[building];
    if (latestInfo == null) return;

    controller.loadFromServer(
      totalBoxes: totalSlots,
      installed: latestInfo.slots
          .where((s) => s.slotNumber != null)
          .map(
            (s) => {
              'slotNumber': s.slotNumber!,
              'spaceType': s.spaceType,
              'level': s.currentLevel,
            },
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.47; // 화면 너비의 45%
    final boxHeight = boxWidth / 2;
    final double availableWidth = MediaQuery.of(context).size.width - 20;

    

    print('boxWidth: $boxWidth');
    print('boxHeight: $boxHeight');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/background.png', fit: BoxFit.cover),
          ),
          Center(
            child: Obx(() {
              final latest = buildingCtrl.infos[building] ?? info;
               final boxNumbers = List.generate(floors * 2, (index) => index + 1);
               
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(floors, (rowIndex) {
                    int start = rowIndex * 2;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBox(
                          boxNumbers[start],
                          boxWidth,
                          boxHeight,
                          controller,
                          latest.slots,
                        ),
                        // SizedBox(width: 0.5),
                        _buildBox(
                          boxNumbers[start + 1],
                          boxWidth,
                          boxHeight,
                          controller,
                          latest.slots,
                        ),
                      ],
                    );
                  }).reversed,
                  SizedBox(height: 230),
                ],
              );
            }),
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Obx(() {
              final isEdit = controller.isEditMode.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: 일반(집+나가기) ↔ 편집(X)
                  GestureDetector(
                    onTap: () {
                      if (controller.isEditMode.value) {
                        controller.cancelEdit(); // ✅ 편집 취소 + 종료
                      } else {
                        // TODO: 일반 모드에서 나가기 동작 (e.g., Get.back();)
                      }
                    },
                    child: Obx(
                      () => controller.isEditMode.value
                          ? const Icon(
                              Icons.close,
                              size: 26,
                              color: Colors.black,
                            )
                          : Row(
                              children: const [
                                Icon(
                                  Icons.home_outlined,
                                  size: 26,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '나가기',
                                  style: TextStyle(
                                    fontFamily: 'Galmuri11',
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // 오른쪽: 일반(코인) ↔ 편집(체크 아이콘 = 완료)
                  isEdit
                      ? GestureDetector(
                          onTap: () async {
                            final ok = await buildingCtrl.installMany(
                              buildingType: building,
                              items: controller.pendingInstalls,
                            );
                            if (ok) {
                              controller.commitLocal();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('설치를 완료했어요!')),
                              );
                              // 서버 최신 상태 다시 가져오고 싶으면:
                              await refreshFromServer();
                              await coinsCtrl.refreshAfterAction(building);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    buildingCtrl.error.value.isEmpty
                                        ? '설치에 실패했어요.'
                                        : buildingCtrl.error.value,
                                  ),
                                ),
                              );
                              // 실패 시 staged 상태 유지(사용자 재시도 가능)
                            }
                          }, // 체크 누르면 편집 종료
                          child: const Icon(
                            Icons.check_circle,
                            size: 26,
                            color: Colors.black,
                          ),
                        )
                      : Obx(() {
                          final type = coinsCtrl.coinTypeOf(building);
                          final iconPath = coinsCtrl.imagePathOf(type);
                          final amount = coinsCtrl.amountOf(type); // 없으면 0

                          return Row(
                            children: [
                              Image.asset(iconPath, width: 20, height: 20),
                              const SizedBox(width: 2),
                              Text(
                                '$amount', // 로딩/에러 상관없이 0 또는 실제 값
                                style: const TextStyle(
                                  fontFamily: 'Galmuri11',
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          );
                        }),
                ],
              );
            }),
          ),

          Positioned(
            bottom: 0,
            left: 20,
            child: ShadowContainer(width: availableWidth),
          ),
          Positioned(
            bottom: 0,
            left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  final isEdit = controller.isEditMode.value;
                  return GestureDetector(
                    onTap: () {
                      if (!isEdit) {
                        controller.enterEditMode(); // 일반 모드에서만 편집 모드 진입
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                      child: isEdit
                          ? const Text(
                              '편집중...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.settings_rounded,
                              size: 24,
                              color: Colors.black,
                            ),
                    ),
                  );
                }),

                CardContainer(
                  width: availableWidth - 5,
                  child: Obx(() {
                    final isEdit = controller.isEditMode.value;
                    final args = Get.arguments;
                    final building = args['building'] as BuildingType;
                    final catalog = SpaceCatalog.byBuilding(building);
                    final latest = buildingCtrl.infos[building] ?? info;
                    return StudyRoomSelector(
                      purchaseList: latest.slots,
                      catalog: catalog,
                      controller: controller,
                      onCardTap: (slotId) => controller.selectSlot(slotId),
                      selectedSlotId: controller.selectedSlotId.value,
                      showOnlyUnlocked: isEdit,
                      buildingType: building,
                      onRefresh: refreshFromServer,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(
    int index,
    double width,
    double height,
    RoomSelectionController controller,
    List<Slot> slots,
  ) {
    return Obx(() {
      final imgPath = controller.stagedBoxImages[index]; // ✅ 여기!
      return GestureDetector(
        onTap: () {
          if (!controller.isEditMode.value) return;
          final selectedId = controller.selectedSlotId.value;
          if (selectedId == null) return;

          // ✅ 선택된 구매 카드의 실제 데이터 찾기
          final selected = slots.firstWhereOrNull((s) => s.id == selectedId);
          if (selected == null) return;

          // 선택된 카드를 이 박스(index)에 “미리 설치”
          controller.stageInstall(
            slotNumber: index,
            spaceId: selected.id,
            spaceType: selected.spaceType,
            level: selected.currentLevel,
          );
        },
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(width: 1, color: Colors.black),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (imgPath != null) Image.asset(imgPath, fit: BoxFit.cover),
              Positioned(
                top: 5,
                left: 5,
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
