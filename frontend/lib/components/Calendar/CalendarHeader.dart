import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/constants/colors.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onTap;

  const CalendarHeader({super.key, required this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${DateFormat('MM').format(date)} ${DateFormat('MMMM').format(date)}",
            style: const TextStyle(
              fontFamily: "GmarketSans",
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: CalendarColor,
            ),
          ),
        ],
      ),
    );
  }
}
