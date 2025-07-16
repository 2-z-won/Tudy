import 'package:flutter/material.dart';

class TodoGroupHeader extends StatelessWidget {
  final String title;
  final Color dotColor;
  final int doneCount;
  final int failCount;
  final VoidCallback onTap;

  const TodoGroupHeader({
    super.key,
    required this.title,
    required this.dotColor,
    required this.doneCount,
    required this.failCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 7, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6, left: 10),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),

          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.check, size: 14, color: Color(0xFF464646)),
              // const SizedBox(width: 4),
              Text(
                '$doneCount',
                style: const TextStyle(fontSize: 10, color: Color(0xFF989898)),
              ),
              // const SizedBox(width: 12),
              Text(
                '  | ',
                style: const TextStyle(fontSize: 10, color: Color(0xFF989898)),
              ),
              Icon(Icons.close, size: 14, color: Color(0xFF464646)),
              // const SizedBox(width: 4),
              Text(
                '$failCount',
                style: const TextStyle(fontSize: 10, color: Color(0xFF989898)),
              ),
              SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}
