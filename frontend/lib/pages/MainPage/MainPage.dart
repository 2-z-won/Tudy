import 'package:flutter/material.dart';
import 'package:frontend/components/Loading/loading_dots.dart';
import 'package:frontend/pages/MainPage/api/building/building_controller.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:frontend/pages/MainPage/coin_dropdown.dart';
import 'package:frontend/pages/MinigamePage/widgets/game_dialog.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});
  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  late final BuildingController buildingCtrl;
  late final CoinsController coinsCtrl;

  @override
  void initState() {
    super.initState();
    buildingCtrl = Get.isRegistered<BuildingController>()
        ? Get.find<BuildingController>()
        : Get.put(BuildingController(), permanent: true);

    coinsCtrl = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController(), permanent: true);

    // ✅ 빌드가 끝난 "다음 프레임"에서만 네트워크 시작 (빌드 중 Obx 갱신 금지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildingCtrl.fetchAll();
      coinsCtrl.fetchCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                buildingButton(
                  type: BuildingType.DEPARTMENT,
                  label: 'DEPARTMENT',
                ),
                const SizedBox(height: 10),
                buildingButton(type: BuildingType.LIBRARY, label: 'LIBRARY'),
                const SizedBox(height: 10),
                buildingButton(type: BuildingType.GYM, label: 'GYM'),
                const SizedBox(height: 10),
                buildingButton(type: BuildingType.CAFE, label: 'CAFE'),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const GameDialog(),
                    );
                  },
                  child: Text("게임"),
                ),
              ],
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
      // 아직 해당 타입 데이터 없고 전체 로딩 중이면 로딩 텍스트
      //final isLoadingThis = buildingCtrl.isLoading.value && info == null;

      final level = info == null ? 1 : buildingCtrl.exteriorLevelOf(type);
      final text = info == null ? '$label 1' : '$label $level';

      return GestureDetector(
        onTap: () async {
          // info가 없으면 로딩 시도 (안전장치)
          if (info == null) {
            await buildingCtrl.fetchBuilding(type);
          }
          final ready = buildingCtrl.infos[type];
          if (ready == null) return; // 실패 시 그냥 무시/토스트 등

          // ✅ floors를 따로 계산하지 말고 info에서 받자
          coinsCtrl.ensureSelectedForBuilding(type);
          Get.toNamed(
            "/inside",
            arguments: {
              'building': type,
              'info': ready, // <-- 통째로 전달!
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.amber,
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      );
    });
  }
}
