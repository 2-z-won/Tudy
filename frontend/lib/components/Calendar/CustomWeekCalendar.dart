import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CalendarHeader.dart';
import 'package:intl/intl.dart';

class CustomWeekCalendar extends StatefulWidget {
  final void Function(DateTime)? onDateSelected;
  const CustomWeekCalendar({super.key, this.onDateSelected});

  @override
  State<CustomWeekCalendar> createState() => _CustomWeekCalendarState();
}

class _CustomWeekCalendarState extends State<CustomWeekCalendar> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  void onPrevWeek() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 7));
      selectedDate = _startOfWeek(currentDate);
    });
  }

  void onNextWeek() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 7));
      selectedDate = _startOfWeek(currentDate);
    });
  }

  DateTime _startOfWeek(DateTime base) {
    // Monday 시작(국내 주차 기준). 일요일 시작 원하면 (weekday % 7) 사용
    final weekday = base.weekday; // Mon=1 ... Sun=7
    return DateTime(
      base.year,
      base.month,
      base.day,
    ).subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _weekDates(DateTime base) {
    final start = _startOfWeek(base);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final week = _weekDates(currentDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CalendarHeader(
                date: currentDate,
                onTap: () {
                  setState(() {
                    currentDate = DateTime.now();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onPrevWeek,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: SubTextColor,
                      ),
                      child: Center(
                        child: const Icon(
                          Icons.chevron_left,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: onNextWeek,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: SubTextColor,
                      ),
                      child: Center(
                        child: const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 요일 헤더
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final date in week)
                _DayCapsule(
                  date: date,
                  isSelected: _isSameYmd(date, selectedDate),
                  onTap: () {
                    setState(() => selectedDate = date);
                    widget.onDateSelected?.call(date);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSameYmd(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCapsule extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCapsule({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  String get _weekdayEng3 {
    // Mon, Tue, ...
    return DateFormat('E', 'en').format(date); // locale ‘en’로 3글자 요일
  }

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? TextColor : Colors.white;
    final txt = isSelected ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 47,
        height: 65,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SubTextColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 요일
              Text(
                _weekdayEng3,
                style: TextStyle(
                  fontSize: 12,
                  color: txt,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              // 일자
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  color: txt,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
