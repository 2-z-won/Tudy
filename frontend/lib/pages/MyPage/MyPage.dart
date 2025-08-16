import 'package:flutter/material.dart';
import 'package:frontend/api/Mypage/mypageController.dart';
import 'package:frontend/api/SignupLogin/controller/login_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/pages/MyPage/StudentCard.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.put(MyPageController());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 60),
        child: Obx(() {
          return Column(
            children: [
              AbsorbPointer(
                absorbing: user.isLoading.value,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          "/editMypage",
                          arguments: {
                            'name': user.name.value,
                            'email': user.userEmail.value,
                            'id': 'testVersion',
                            'password': 'test123!',
                            'birth': '2000.01.01',
                            'college': user.college.value,
                            'department': user.department.value,
                          },
                        );
                      },
                      child: StudentCard(
                        name: user.name.value,
                        birth: "2004.12.25",
                        college: user.college.value,
                        department: user.department.value,
                        profileImageAsset: 'images/profile.jpg',
                        qrImageAsset: 'images/profile.jpg',
                      ),
                    ),

                    if (user.isLoading.value)
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.black.withOpacity(0.12),
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem(
                    user.todayGoalCount.value,
                    '오늘의목표',
                    () => Get.toNamed('/Todo'),
                  ),
                  _statItem(
                    user.friendCount.value,
                    '친구',
                    () => Get.toNamed('/friend'),
                  ),
                  _statItem(1, '그룹', () => Get.toNamed('/group')),
                ],
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  //로그아웃
                  final loginController = Get.find<LoginController>();
                  loginController.logout();
                },
                child: Text(
                  '휴학하기',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF4A4A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFFF4A4A),
                    letterSpacing: 0.14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }),
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
