import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CustomMonthCalendar.dart';
import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
import 'package:frontend/components/Todo/TodoList.dart';
import 'package:frontend/components/Todo/TodoGroupHeader.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  bool isMonthView = true; // ✅ 상태: 월간/주간 전환

  void toggleView() {
    setState(() {
      isMonthView = !isMonthView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            // 상단 토글 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: toggleView,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // 텍스트 색상
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero, // 최소 크기 제거 (필요 시)
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isMonthView ? "Month 🟰" : "Week 🟰",
                    style: const TextStyle(fontSize: 12, color: SubTextColor),
                  ),
                ),
              ],
            ),

            // ✅ 달력 뷰: Month ↔ Week
            isMonthView
                ? const CustomMonthCalendar()
                : const CustomWeekCalendar(),

            const SizedBox(height: 20),

            // 투두 헤더 + 카드 예시
            const TodoGroupHeader(
              title: '공부',
              dotColor: Color(0xFF4D4AFF),
              doneCount: 10,
              failCount: 0,
            ),
            const TodoItemCard(
              text: '알고리즘 공부하기',
              isGroup: true,
              isDone: true,
              mainColor: Color(0xFF4D4AFF),
            ),
            const TodoItemCard(
              text: '알고리즘 공부하기',
              isGroup: false,
              isDone: false,
              mainColor: Color(0xFF4D4AFF),
            ),
          ],
        ),
      ),
    );
  }
}
