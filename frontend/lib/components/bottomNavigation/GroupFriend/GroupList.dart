import 'package:flutter/material.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupFriendItem.dart';
import 'package:frontend/constants/colors.dart';

class GroupDropdownCard extends StatefulWidget {
  final String title;

  const GroupDropdownCard({super.key, required this.title});

  @override
  State<GroupDropdownCard> createState() => _GroupDropdownCardState();
}

class _GroupDropdownCardState extends State<GroupDropdownCard> {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  // vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
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
                    title: "☘️ 그룹 참여 신청 ☘️",
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
                  SizedBox(height: 16),
                  CardContainer(
                    title: "🔥 오늘의 그룹 목표 🔥",
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

class CardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CardContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ⚪ 메인 카드 박스
        Container(
          margin: const EdgeInsets.only(top: 10), // 제목과의 간격
          padding: const EdgeInsets.fromLTRB(10, 15, 15, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFE1DDD4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),

        // 🔥 제목 박스 (오버레이처럼)
        Positioned(
          left: 12,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white, // 배경색을 박스 색과 같게!
            child: Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
