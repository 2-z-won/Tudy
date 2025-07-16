import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CalendarHeader.dart';

class CustomWeekCalendar extends StatefulWidget {
  final void Function(DateTime)? onDateSelected;
  const CustomWeekCalendar({super.key, this.onDateSelected});

  @override
  State<CustomWeekCalendar> createState() => _CustomWeekCalendarState();
}

class _CustomWeekCalendarState extends State<CustomWeekCalendar> {
  DateTime currentDate = DateTime.now();

  void onPrevWeek() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 7));
    });
  }

  void onNextWeek() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 7));
    });
  }

  DateTime get startOfWeek {
    final weekday = currentDate.weekday;
    return currentDate.subtract(Duration(days: weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekStart = startOfWeek;

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
              onPressed: onPrevWeek,
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
              onPressed: onNextWeek,
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

        GridView.count(
          crossAxisCount: 7,
          crossAxisSpacing: 17,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(7, (index) {
            final date = weekStart.add(Duration(days: index));
            final isToday =
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            return Center(
              child: GestureDetector(
                onTap: () {
                  widget.onDateSelected?.call(date); // ✅ 날짜 선택 콜백 실행
                },
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
                      '${date.day}',
                      style: const TextStyle(fontSize: 14, color: SubTextColor),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
