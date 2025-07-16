import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String birth;
  final String college;
  final String department;
  final String profileImageAsset;
  final String qrImageAsset;

  const StudentCard({
    super.key,
    required this.name,
    required this.birth,
    required this.college,
    required this.department,
    required this.profileImageAsset,
    required this.qrImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 파란 배경
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2353A6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '학  생  증',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // 프로필 카드와 겹치지 않도록 여백
              // 이름, 생년월일, 소속
              Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 25, left: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('이름', name),
                    const SizedBox(height: 17),
                    _infoRow('생년월일', birth),
                    const SizedBox(height: 17),
                    _infoRow('소속', '$college\n$department'),
                  ],
                ),
              ),

              // 하단 로고 + 텍스트
              Container(
                width: double.infinity,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pnu_logo.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '부  산  대  학  교',
                      style: TextStyle(
                        color: Color(0xFF2353A6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Positioned 프로필 + QR
        Positioned(
          top: 38,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 210,
                height: 110,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Color(0xFFF1F1F1), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      child: Image.asset(
                        profileImageAsset,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      qrImageAsset,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            title,
            style: const TextStyle(color: Color(0xFF989898), fontSize: 10),
          ),
        ),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}
