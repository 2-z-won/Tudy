import 'package:flutter/material.dart';
import 'package:frontend/pages/Inside/CardSelector.dart';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';
import 'package:frontend/pages/MainPage/api/building/building_controller.dart';
import 'package:frontend/pages/MainPage/api/building/building_model.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class InsidePageView extends StatelessWidget {
  const InsidePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final building = args['building'] as BuildingType;
    final info = args['info'] as BuildingInfo;

    final floors = info.config.floors;
    final currentFloor = info.building.currentFloor;

    final totalSlots = floors * 2;

    final RoomSelectionController controller = Get.put(
      RoomSelectionController(totalSlots),
    );

    final buildingCtrl = Get.find<BuildingController>();
    final coinsCtrl = Get.find<CoinsController>();
    coinsCtrl.ensureSelectedForBuilding(building);

    controller.loadFromServer(
      totalBoxes: totalSlots,
      installed: info.slots
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

    Future<void> refreshFromServer() async {
      await buildingCtrl.fetchBuilding(building); // ✅ 결과는 infos에 반영됨
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

    final boxNumbers = List.generate(floors * 2, (index) => index + 1);
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.47; // 화면 너비의 45%
    final boxHeight = boxWidth / 2;
    final double availableWidth = MediaQuery.of(context).size.width - 20;

    final latest = buildingCtrl.infos[building] ?? info;

    print('boxWidth: $boxWidth');
    print('boxHeight: $boxHeight');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/background.png', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
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
            ),
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
