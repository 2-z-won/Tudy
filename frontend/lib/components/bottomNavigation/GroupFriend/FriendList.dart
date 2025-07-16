import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupFriendItem.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupList.dart';
import 'package:frontend/constants/colors.dart';

class FriendDropdownCard extends StatefulWidget {
  final String name;

  const FriendDropdownCard({super.key, required this.name});

  @override
  State<FriendDropdownCard> createState() => _FriendDropdownCardState();
}

class _FriendDropdownCardState extends State<FriendDropdownCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE1DDD4)),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // 🔼 제목 바 (펼치기 전 높이 40, 내부 패딩 있음)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE1DDD4)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image.asset("/images/profile.jpg"),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: SubTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔽 펼쳐진 내용
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardContainer(
                    title: "🔥 함께하는 목표 🔥",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        GoalItem(text: "알고리즘 공부하기", isDone: false),
                        GoalItem(text: "알고리즘 공부하기", isDone: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
