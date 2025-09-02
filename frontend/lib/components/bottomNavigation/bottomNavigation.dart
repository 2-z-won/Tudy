import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigation/bottomNavigationController.dart';
import 'package:get/get.dart';
import 'dart:ui' show lerpDouble;

class MyBottomNavigation extends GetView<MyBottomNavigationController> {
  const MyBottomNavigation({super.key});

  static const _icons = [
    Icons.calendar_today_outlined, // 0
    Icons.timer_outlined, // 1
    Icons.book_outlined, // 3 (index 2는 로고라 건너뜀)
    Icons.settings_outlined, // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sel = controller.selectedIndex.value;
      final shadow = controller.shadowIndex.value;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(27, 0, 41, 77),
              blurRadius: 12,
              spreadRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            // ── 가운데(2)는 로고 이미지, 나머지는 아이콘 ─────────────────
            if (index == 2) {
              final isSelected = sel == 2;

              return GestureDetector(
                onTap: () => controller.changeIndex(2),
                child: TweenAnimationBuilder<double>(
                  // 선택되면 1.0, 해제되면 0.0 으로 부드럽게 보간
                  tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    // t: 0→1
                    final double size = lerpDouble(
                      32,
                      44,
                      t,
                    )!; // 기본 32 → 선택시 45
                    return SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: Image.asset(
                            'images/pnu_logo.png', // ✅ 고정
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            // ── 아이콘 버튼들 (0,1,3,4) ──────────────────────────────────
            final displayIndex = index > 2 ? index - 1 : index;
            final isSelected = sel == index;

            return GestureDetector(
              onTap: () => controller.changeIndex(index),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(isSelected),
                tween: Tween(
                  begin: isSelected ? 1 : 0,
                  end: isSelected ? 1 : 0,
                ),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) {
                  final bgSize = lerpDouble(0, 44, t)!; // 배경 원 (0→44)
                  final iconSize = lerpDouble(26, 34, t)!; // 아이콘 (28→35)
                  final iconColor = t > 0.5
                      ? Colors.white
                      : const Color(0xFF3F3B33);

                  return SizedBox(
                    width: 45,
                    height: 45,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: bgSize,
                          height: bgSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF303030),
                            boxShadow: t > 0
                                ? const [
                                    BoxShadow(
                                      color: Color.fromARGB(59, 55, 55, 55),
                                      blurRadius: 12,
                                      spreadRadius: 4,
                                      offset: Offset(0, 0),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        Icon(
                          _icons[displayIndex],
                          size: iconSize,
                          color: iconColor,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      );
    });
  }
}
