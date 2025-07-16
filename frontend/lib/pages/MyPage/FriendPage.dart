import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/FriendList.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupFriendItem.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/JoinAddFindfield.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupList.dart';
import 'package:frontend/constants/colors.dart';

class Friendpage extends StatefulWidget {
  const Friendpage({super.key});

  @override
  State<Friendpage> createState() => _GroupPageState();
}

class _GroupPageState extends State<Friendpage> {
  final TextEditingController _groupController = TextEditingController();

  @override
  void dispose() {
    _groupController.dispose();
    super.dispose();
  }

  void onJoin() {
    final groupName = _groupController.text.trim();
    if (groupName.isNotEmpty) {
      print("그룹 참여 요청: $groupName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🟨 메인 콘텐츠
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 45,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "친구",
                    style: TextStyle(fontSize: 14, color: SubTextColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(height: 1, color: Color(0xFFF4EBEB)),
              ),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    JoinAddField(
                      hinttext: "친구명을 입력하세요",
                      button: "SEND",
                      controller: _groupController,
                      onJoin: onJoin,
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Divider(height: 1, color: Color(0xFFF4EBEB)),
                    ),
                    CardContainer(
                      title: "✉️ 친구 신청 목록 ✉️",
                      child: Column(
                        children: [
                          JoinRequestRow(
                            name: "김효정",
                            imageAsset: 'assets/profile1.jpg',
                          ),
                          SizedBox(height: 10),
                          JoinRequestRow(
                            name: "김효정",
                            imageAsset: 'assets/profile2.jpg',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Divider(height: 1, color: Color(0xFFF4EBEB)),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "👥 나의 친구",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    FriendDropdownCard(name: "김효정"),
                  ],
                ),
              ),
            ],
          ),

          // 🟩 상단 앱바 스타일 커스텀
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 45,
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 15,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                        color: Color(0xFF1E1E1E),
                      ),
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
}
