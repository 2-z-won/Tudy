import 'package:flutter/material.dart';
import 'package:frontend/pages/Inside/Card/CustomCard.dart';
import 'package:frontend/pages/Inside/Card/SelectCustiomCard.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 83,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 56,
                      height: 75,
                      decoration: BoxDecoration(color: Colors.grey.shade800),
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
                      size: const Size(64, 83),
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
                      height: 75,
                      decoration: BoxDecoration(color: Colors.grey.shade800),
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
    );
  }
}
