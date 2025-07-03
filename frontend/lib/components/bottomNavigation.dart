import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigationController.dart';
import 'package:get/get.dart';

class MyBottomNavigation extends GetView<MyBottomNavigationController> {
  const MyBottomNavigation({super.key});

  static const _icons = [
    Icons.calendar_today_outlined, // 0
    Icons.timer_outlined, // 1
    Icons.book_outlined, // 2
    Icons.settings_outlined, // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sel = controller.selectedIndex.value;
      final shadow = controller.shadowIndex.value;

      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 아이콘 4개 (0~3)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                if (index == 2) return const SizedBox(width: 80); // 로고 자리

                final displayIndex = index > 2 ? index - 1 : index;
                final isSelected = sel == index;
                final showShadow = shadow == index;

                return GestureDetector(
                  onTap: () => controller.changeIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: showShadow
                          ? [
                              // BoxShadow(
                              //   color: Colors.blue.withOpacity(0.4),
                              //   blurRadius: 12,
                              //   spreadRadius: 2,
                              //   offset: const Offset(0, 4),
                              // ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _icons[displayIndex],
                      size: 30,
                      color: isSelected
                          ? Color.fromARGB(255, 238, 213, 170)
                          : Color(0xFF3F3B33),
                    ),
                  ),
                );
              }),
            ),

            // 중앙 로고 (index == 2)
            Positioned(
              top: -10,
              child: GestureDetector(
                onTap: () => controller.changeIndex(2),
                child: Obx(() {
                  final showShadow = controller.shadowIndex.value == 2;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: const DecorationImage(
                        image: AssetImage('lib/images/pnu_logo.png'),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: showShadow
                          ? [
                              BoxShadow(
                                color: Color(0xFFF2E9DA),
                                blurRadius: 16,
                                spreadRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}
