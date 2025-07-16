import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CalendarHeader.dart';

class CustomMonthCalendar extends StatefulWidget {
  const CustomMonthCalendar({super.key});

  @override
  State<CustomMonthCalendar> createState() => _CustomMonthCalendarState();
}

class _CustomMonthCalendarState extends State<CustomMonthCalendar> {
  DateTime currentDate = DateTime.now();

  void onPrevMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1);
    });
  }

  void onNextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = currentDate.year;
    final month = currentDate.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final startWeekday = firstDayOfMonth.weekday; // 1 (Mon) ~ 7 (Sun)
    final lastDay = DateTime(year, month + 1, 0).day;

    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 상단 월/연도 + 아이콘 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevMonth,
              iconSize: 24,
              splashRadius: 20,
            ),
            const SizedBox(width: 8),
            CalendarHeader(
              date: currentDate,
              onTap: () {
                setState(() {
                  currentDate = DateTime.now();
                });
              },
            ),

            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
              iconSize: 24,
              splashRadius: 20,
            ),
          ],
        ),

        const SizedBox(height: 5),

        // 요일 헤더
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          crossAxisSpacing: 17, // 날짜와 동일
          mainAxisSpacing: 0,
          physics: const NeverScrollableScrollPhysics(),
          children: ['월', '화', '수', '목', '금', '토', '일']
              .map(
                (day) => Center(
                  child: Text(
                    day,
                    style: const TextStyle(fontSize: 12, color: SubTextColor),
                  ),
                ),
              )
              .toList(),
        ),

        // 날짜 그리기
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lastDay + (startWeekday - 1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 17,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            if (index < startWeekday - 1) {
              return const SizedBox(); // 빈칸
            } else {
              final day = index - startWeekday + 2;
              final isToday =
                  today.year == year &&
                  today.month == month &&
                  today.day == day;

              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: isToday
                      ? BoxDecoration(
                          color: const Color(0xFFFFE5E5),
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Center(
                    child: Text(
                      '$day',
                      style: const TextStyle(fontSize: 14, color: SubTextColor),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
