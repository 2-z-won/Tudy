// 파일명: study_room_selector.dart
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';
import 'package:frontend/pages/MainPage/api/building/building_controller.dart';
import 'package:frontend/pages/MainPage/api/building/building_model.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';

class StudyRoomSelector extends StatelessWidget {
  final List<Slot> purchaseList;
  final int? selectedSlotId;
  final void Function(int?) onCardTap;
  final bool showOnlyUnlocked;
  final List<SpaceDef> catalog;
  final RoomSelectionController controller;
  final Future<void> Function() onRefresh;
  final BuildingType buildingType;

  const StudyRoomSelector({
    required this.purchaseList,
    required this.catalog,
    required this.controller,
    required this.onCardTap,
    required this.selectedSlotId,
    this.showOnlyUnlocked = false,
    required this.onRefresh,
    required this.buildingType,
    super.key,
  });

  SpaceDef _defOf(String spaceType) =>
      catalog.firstWhere((d) => d.id == spaceType, orElse: () => catalog.first);

  @override
  Widget build(BuildContext context) {
    // Obx 제거 - observable 변수가 없음
    final purchasedCards = purchaseList.map((s) {
        final def = _defOf(s.spaceType);
        return {
          'kind': 'purchased',
          'slotId': s.id, // 고유 id (선택에 사용)
          'spaceType': s.spaceType, // 그룹핑/카운팅용
          'name': def.nameKor,
          'image': def.image,
          'price': def.price,
          'installed': s.slotNumber != null, // 설치 여부 배지
        };
      }).toList();

      final counts = <String, int>{};
      for (final s in purchaseList) {
        counts.update(s.spaceType, (v) => v + 1, ifAbsent: () => 1);
      }

      final lockedCards = <Map<String, dynamic>>[];
      for (final def in catalog) {
        final purchasedCount = counts[def.id] ?? 0;
        final remain = (def.maxInstall - purchasedCount).clamp(
          0,
          def.maxInstall,
        );
        for (int i = 0; i < remain; i++) {
          lockedCards.add({
            'kind': 'lock',
            'slotId': null, // 아직 구매 전이니 id 없음
            'spaceType': def.id,
            'name': def.nameKor,
            'image': def.image,
            'price': def.price,
            'installed': false,
          });
        }
      }

      final visibleRooms = showOnlyUnlocked
          ? [...purchasedCards] // 편집 모드: 구매된 것만
          : [...purchasedCards, ...lockedCards]; // 일반 모드: 구매된 것 + 잠금

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: visibleRooms.map((room) {
          final kind = room['kind'] as String; // 'purchased' | 'lock'
          final slotId = room['slotId'] as int?;
          final isSelected =
              showOnlyUnlocked && slotId != null && slotId == selectedSlotId;

          return Transform.translate(
            offset: isSelected ? const Offset(0, -3) : Offset.zero,
            child: GestureDetector(
              onTap: () async {
                if (kind == 'lock') {
                  // ✅ 구매 플로우
                  final def = _defOf(room['spaceType'] as String);
                  final ok = await _confirmPurchase(context, def);
                  if (ok != true) return;

                  final buildingCtrl = Get.find<BuildingController>();
                  final success = await buildingCtrl.purchaseSpace(
                    buildingType: buildingType,
                    spaceType: def.id, // ← 서버가 id 요구 시: spaceId로 변경
                  );
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          buildingCtrl.error.value.isEmpty
                              ? '구매에 실패했어요.'
                              : buildingCtrl.error.value,
                        ),
                      ),
                    );
                    return;
                  }

                  // ✅ 서버에서 최신 슬롯 재조회 → 부모가 넘겨준 onRefresh 수행
                  await onRefresh();

                  final coinsCtrl = Get.find<CoinsController>();
                  await coinsCtrl.refreshAfterAction(buildingType);

                  // 선택 상태/편집 상태는 그대로 두거나 필요시 초기화
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('구매가 완료됐어요!')));
                  return;
                }
                // 구매 카드이고, 편집 모드에서만 선택 가능
                if (showOnlyUnlocked && slotId != null) {
                  onCardTap(isSelected ? null : slotId);
                }
              },
              child: _buildRoomCard(room),
            ),
          );
        }).toList(),
      );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final isLock = room['kind'] == 'lock';
    final installed = room['installed'] as bool;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 85,
                height: 90,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 156, 131, 111),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: RoomCard(room['image']),
              ),
              if (!isLock && installed) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 5,
                  child: Center(
                    child: Container(
                      // width: 81,
                      // height: 86,
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          255,
                          111,
                          1,
                        ).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Text(
                        '설치됨',
                        style: TextStyle(
                          fontFamily: 'Galmuri11',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (isLock) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 81,
                      height: 86,
                      padding: EdgeInsets.only(top: 22),
                      decoration: BoxDecoration(
                        color: Color(0xFF433123).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 28),
                          Text(
                            '${room['price']}',
                            style: TextStyle(
                              fontFamily: 'Galmuri11',
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            room['name'],
            style: TextStyle(
              fontFamily: 'Galmuri11',
              color: Colors.white,
              fontSize: 14,
            ), //폰트 바꾸고는 14로 조정해야함
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmPurchase(BuildContext context, SpaceDef def) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'purchase',
      barrierColor: Colors.black.withOpacity(0.35), // 뒤 배경 살짝 어둡게
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim, secondaryAnim) {
        // 여기서 Dialog 대신 Center로 직접 배치해도 됨
        return Center(child: _PurchaseDialogBody(def: def));
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        // 곡선 지정 (살짝 “튀어오르는” 느낌은 easeOutBack 추천)
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }
}

class RoomCard extends StatelessWidget {
  final String imagePath;

  const RoomCard(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 81,
      height: 86,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF1F1E1B), width: 1.5),
        borderRadius: BorderRadius.circular(0),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}

class ShadowContainer extends StatelessWidget {
  final double width;

  const ShadowContainer({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 132,
      decoration: const BoxDecoration(
        color: Color(0xFF312316),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0)),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final double width;
  final Widget child;

  const CardContainer({super.key, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 135,
      padding: const EdgeInsets.only(top: 10, left: 10, bottom: 7),
      decoration: const BoxDecoration(
        color: Color(0xFF85664A),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}

class _PurchaseDialogBody extends StatelessWidget {
  final SpaceDef def;
  const _PurchaseDialogBody({required this.def});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero, // 원본 이미지 크기 유지
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ 원본 배경 이미지 (그대로)
          Image.asset('assets/images/button/purchase_bg.png', fit: BoxFit.none),

          // ✅ 이미지 위에 내용
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 가격
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/coin/ACADEMIC_SAEDO.png",
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 1),
                    Text(
                      "${def.price} 코인으로",
                      style: const TextStyle(
                        fontFamily: 'Galmuri11',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  "${def.nameKor}을(를) 구매할까요?",
                  style: const TextStyle(
                    fontFamily: 'Galmuri11',
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // 버튼들 (눌림 효과 포함)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PressableButton(
                      onTap: () => Navigator.of(context).pop(false),
                      label: '취소',
                      imagePath: "assets/images/button/cancel_purchase.png",
                    ),
                    const SizedBox(width: 10),
                    PressableButton(
                      onTap: () => Navigator.of(context).pop(true),
                      label: '구매',
                      imagePath: "assets/images/button/purchase.png",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PressableButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final String imagePath;

  const PressableButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.imagePath,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9; // 살짝 줄이기
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 원래 크기
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 93,
              height: 34,
              child: Image.asset(widget.imagePath),
            ),
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Galmuri11',
                color: TextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
