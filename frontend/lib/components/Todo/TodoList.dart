import 'package:flutter/material.dart';

class TodoItemCard extends StatelessWidget {
  final String text;
  final bool isGroup;
  final bool isDone;
  final Color subColor;

  const TodoItemCard({
    super.key,
    required this.text,
    required this.isGroup,
    required this.isDone,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDone ? subColor : Colors.white;
    final Color border = subColor;
    final Color iconBg = isDone ? Colors.white : Colors.transparent;
    final Color iconColor = subColor;

    final EdgeInsets contentPadding = isDone
        ? const EdgeInsets.fromLTRB(5 + 3, 5, 15, 5) // border가 없으므로 보정
        : const EdgeInsets.fromLTRB(5, 5, 12, 5);

    return Container(
      height: 40,
      padding: contentPadding,
      decoration: BoxDecoration(
        color: bgColor,
        border: isDone ? null : Border.all(color: border, width: 3),
        borderRadius: BorderRadius.circular(13.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 체크 아이콘 배경 처리
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check, size: 23, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          Text(
            isGroup ? '그룹' : '개인',
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
