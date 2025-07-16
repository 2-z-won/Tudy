import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/JoinAddFindfield.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupList.dart';
import 'package:frontend/constants/colors.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
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
                    "그룹",
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
                      hinttext: "그룹명을 입력하세요",
                      button: "JOIN",
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
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "👥 나의 그룹",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    GroupDropdownCard(title: "SW해커톤"),
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
                  Positioned(
                    right: 15,
                    top: 15,
                    child: GestureDetector(
                      onTap: _showCreateGroupDialog, // 👈 이 함수 연결
                      child: Icon(
                        Icons.add_rounded,
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

  void _showCreateGroupDialog() {
    String groupName = '';
    List<String> passwordDigits = List.filled(6, '');

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(110, 110, 110, 0.2),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 그림자와 둥근 모서리 표현을 위해
          child: Container(
            width: 340,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 12.9,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "그룹 생성",
                  style: TextStyle(
                    fontSize: 13,
                    color: SubTextColor,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE1DDD4)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) => groupName = value,
                    decoration: const InputDecoration(
                      hintText: "그룹명을 입력하세요",
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA6A6A6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "PASSWORD",
                  style: TextStyle(
                    fontSize: 13,
                    color: SubTextColor,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 35,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6E5),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Color(0xFFE1DDD4)),
                      ),
                      child: Text(
                        passwordDigits[index],
                        style: const TextStyle(fontSize: 16, color: TextColor),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "완료",
                    style: TextStyle(
                      fontSize: 14,
                      color: SubTextColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
