import 'package:flutter/material.dart';

class TodoGroupHeader extends StatelessWidget {
  final String title;
  final Color dotColor;
  final int doneCount;
  final int failCount;

  const TodoGroupHeader({
    super.key,
    required this.title,
    required this.dotColor,
    required this.doneCount,
    required this.failCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 6, left: 10),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
          const Spacer(),
          Text(
            '✔️ $doneCount | ✖️ $failCount ',
            style: const TextStyle(fontSize: 10, color: Color(0xFF989898)),
          ),
        ],
      ),
    );
  }
}
