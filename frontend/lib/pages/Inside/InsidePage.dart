import 'package:flutter/material.dart';
import 'package:frontend/pages/Inside/Card/CardContainer.dart';
import 'package:frontend/pages/Inside/Card/CustomCard.dart';
import 'package:frontend/pages/Inside/Card/SelectCustiomCard.dart';
import 'package:frontend/pages/Inside/CardSelector.dart';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:get/get.dart';

class InsidePageView extends StatelessWidget {
  InsidePageView({super.key});

  final RoomSelectionController controller = Get.put(RoomSelectionController());

  @override
  Widget build(BuildContext context) {
    final boxNumbers = List.generate(10, (index) => index + 1);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (rowIndex) {
                  int start = rowIndex * 2;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBox(
                        boxNumbers[start],
                        boxWidth,
                        boxHeight,
                        controller,
                      ),
                      // SizedBox(width: 0.5),
                      _buildBox(
                        boxNumbers[start + 1],
                        boxWidth,
                        boxHeight,
                        controller,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽: 나가기
                Row(
                  children: [
                    Icon(Icons.home_outlined, size: 26, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      '나가기',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                // 오른쪽: 코인
                Row(
                  children: [
                    Image.asset('images/coin.png', width: 20, height: 20),
                    const SizedBox(width: 2),
                    Text(
                      '1,000',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 20,
            child: ShadowContainer(width: availableWidth),
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 25,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       Icon(Icons.settings_rounded),
          //       CardContainer(
          //         width: availableWidth - 5,
          //         child: Obx(
          //           () => StudyRoomSelector(
          //             onCardTap: controller.selectCard,
          //             selectedCardName: controller.selectedCard.value,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 25,
            child: PixelCardContainer(
              width: availableWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    height: 79,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 56,
                            height: 71,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                            ),
                            child: Image.asset(
                              'assets/images/image.png', // 정확한 경로
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CustomPaint(
                            painter: const CustomCardPainter(
                              color: Color(0xFF3A1F0B),
                              pixelSize: 4,
                            ),
                            size: const Size(64, 79),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 85,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 56,
                            height: 71,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                            ),
                            child: Image.asset(
                              'assets/images/image.png', // 정확한 경로
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CustomPaint(
                            painter: const SelectCustomCardPainter(
                              color: Color(0xFF3A1F0B),
                              pixelSize: 3,
                            ),
                            size: const Size(70, 85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
  ) {
    return Obx(() {
      final value = controller.boxValues[index]?.value;
      return GestureDetector(
        onTap: () => controller.assignToBox(index),
        child: Container(
          width: width,
          height: height,
          // alignment: Alignment.center,
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(width: 1, color: Colors.black),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset('images/image.png', fit: BoxFit.fill),
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     if (value != null)
          //       Text(
          //         value,
          //         style: TextStyle(
          //           fontSize: 20,
          //           color: Colors.red,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),

          //     Positioned(
          //       top: 5,
          //       left: 5,
          //       child: Text(
          //         index.toString(),
          //         style: TextStyle(color: Colors.white, fontSize: 16),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      );
    });
  }
}
