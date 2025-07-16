import 'package:flutter/material.dart';
import 'package:frontend/pages/Inside/CardSelector.dart';

class InsidePageView extends StatelessWidget {
  const InsidePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final double availableWidth = MediaQuery.of(context).size.width - 20;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 15, // 상단 여백 (상황에 따라 조절)
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
                    Icon(
                      Icons.monetization_on_outlined,
                      color: const Color.fromARGB(255, 241, 208, 60),
                    ),
                    const SizedBox(width: 4),
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
          Positioned(
            bottom: 0,
            left: 25,
            child: CardContainer(
              width: availableWidth - 5,
              child: StudyRoomSelector(),
            ),
          ),
        ],
      ),
    );
  }
}
