import 'package:flutter/material.dart';

Color getSubColor(Color mainColor) {
  final r = mainColor.red;
  final g = mainColor.green;
  final b = mainColor.blue;

  if (r >= g && r >= b) {
    return Color.fromARGB(255, r, 0xE1, 0xE1);
  } else if (g >= r && g >= b) {
    return Color.fromARGB(255, 0xE1, g, 0xE1);
  } else {
    return Color.fromARGB(255, 0xE1, 0xE1, b);
  }
}

class TodoItemCard extends StatelessWidget {
  final String text;
  final bool isGroup;
  final bool isDone;
  final Color mainColor;

  const TodoItemCard({
    super.key,
    required this.text,
    required this.isGroup,
    required this.isDone,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color subColor = getSubColor(mainColor); // ✅ 서브컬러 계산

    final Color bgColor = isDone ? subColor : Colors.white;
    final Color border = subColor;
    final Color iconBg = isDone ? Colors.white : Colors.transparent;
    final Color iconColor = subColor;

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
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
