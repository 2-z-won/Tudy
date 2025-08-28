import 'package:flutter/material.dart';
import 'package:frontend/components/Loading/loading_dots.dart';
import 'package:frontend/pages/MainPage/api/building/building_controller.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:frontend/pages/MainPage/coin_dropdown.dart';
import 'package:frontend/pages/MinigamePage/widgets/game_dialog.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});
  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  late final BuildingController buildingCtrl = Get.put(BuildingController());
  late final CoinsController coinsCtrl = Get.put(CoinsController());

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final uid = await getUserIdFromStorage();
    if (uid == null) {
      debugPrint('❌ 저장된 사용자 ID가 없습니다.');
      return;
    }
    await buildingCtrl.fetchAll();
    await coinsCtrl.fetchAllTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fitWidth, // 가로 꽉 채움, 세로는 비율에 맞게
              width: double.infinity,
            ),
          ),

          // Department (정중앙에서 위로 150)
          Center(
            child: Transform.translate(
              offset: const Offset(-5, -195),
              child: buildingButton(
                type: BuildingType.DEPARTMENT,
                label: 'DEPARTMENT',
              ),
            ),
          ),

          // Library (정중앙에서 오른쪽 150, 위로 100)
          Center(
            child: Transform.translate(
              offset: const Offset(125, -137),
              child: buildingButton(
                type: BuildingType.LIBRARY,
                label: 'LIBRARY',
              ),
            ),
          ),

          // Arcade (정중앙에서 왼쪽 80, 위로 30)
          Center(
            child: Transform.translate(
              offset: const Offset(-125, -97),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const GameDialog(),
                  );
                },
                child: Image.asset(
                  'assets/images/buildings/arcade.png',
                  width: 160, // 원하는 크기로 조절
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Cafe (정중앙에서 아래로 200, 왼쪽으로 70)
          Center(
            child: Transform.translate(
              offset: const Offset(-85, 133),
              child: buildingButton(type: BuildingType.CAFE, label: 'CAFE'),
            ),
          ),

          // Gym (정중앙에서 아래로 200, 오른쪽으로 60)
          Center(
            child: Transform.translate(
              offset: const Offset(95, 123),
              child: buildingButton(type: BuildingType.GYM, label: 'GYM'),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: CoinDropdownSimple(ctrl: coinsCtrl, showTypeLabel: false),
          ),
          // Positioned.fill(
          //   child: Obx(() {
          //     final loading =
          //         buildingCtrl.isLoading.value || coinsCtrl.isLoading.value;
          //     if (!loading) return const SizedBox.shrink();
          //     return Container(
          //       //color: Colors.black12,
          //       child: Center(
          //         child: SequentialBounceLoader(
          //           color: Colors.white,
          //           size: 12,
          //           gap: 10,
          //           duration: Duration(milliseconds: 300), // 하나가 올라갔다 내려오는 시간
          //           maxTranslateY: 18, // 튀는 높이
          //         ),
          //       ),
          //     );
          //   }),
          // ),
        ],
      ),
    );
  }

  Widget buildingButton({required BuildingType type, required String label}) {
    return Obx(() {
      final info = buildingCtrl.infos[type];
      final level = info == null ? 1 : buildingCtrl.exteriorLevelOf(type);
      final text = info == null ? '$label 1' : '$label $level';

      return GestureDetector(
        onTap: () async {
          if (info == null) {
            await buildingCtrl.fetchBuilding(type);
          }
          final ready = buildingCtrl.infos[type];
          if (ready == null) return;

          coinsCtrl.ensureSelectedForBuilding(type);
          Get.toNamed("/inside", arguments: {'building': type, 'info': ready});
        },
        child: Builder(
          builder: (context) {
            // assets/images/buildings/ 경로에서 로드
            final buildingPath = 'assets/images/buildings/${type.name.toLowerCase()}.png';
            
            print('🖼️ 건물 이미지 경로: $buildingPath');
            
            return Image.asset(
              buildingPath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('🔥 건물 이미지 로드 실패: $buildingPath - $error');
                // 실패하면 대체 이미지 표시
                return Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type == BuildingType.DEPARTMENT ? Icons.school :
                        type == BuildingType.LIBRARY ? Icons.local_library :
                        type == BuildingType.CAFE ? Icons.local_cafe :
                        type == BuildingType.GYM ? Icons.fitness_center :
                        Icons.business,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }
}
