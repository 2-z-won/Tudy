import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/pages/MyPage/StudentCard.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 40, right: 40, top: 60),
        child: Column(
          children: [
            StudentCard(
              name: "아무개",
              birth: "2004.12.25",
              college: "정보의생명공학대학",
              department: "정보컴퓨터공학부",
              profileImageAsset: 'images/profile.jpg',
              qrImageAsset: 'images/profile.jpg',
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(10, '오늘의목표', () => Get.toNamed('/todo')),
                _statItem(10, '친구', () => Get.toNamed('/friend')),
                _statItem(10, '그룹', () => Get.toNamed('/group')),
              ],
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                //로그아웃
              },
              child: Text(
                '휴학하기',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF4A4A),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFFF4A4A),
                  letterSpacing: 0.14, // 약 1% of 14pt
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(int count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 22, color: SubTextColor),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: SubTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
