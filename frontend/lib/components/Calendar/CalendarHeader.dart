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
            DateFormat('MM').format(date),
            style: const TextStyle(fontSize: 50, color: CalendarColor),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 1,
            height: 50,
            color: CalendarColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMMM').format(date),
                style: const TextStyle(fontSize: 15, color: CalendarColor),
              ),
              Text(
                DateFormat('yyyy').format(date),
                style: const TextStyle(fontSize: 15, color: CalendarColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
