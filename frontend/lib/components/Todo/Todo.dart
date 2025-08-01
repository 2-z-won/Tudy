import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/TodoItem.dart';
import '../Todo/TodoGroupHeader.dart';
import '../Todo/TodoList.dart';

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

class Todo extends StatelessWidget {
  final TodoItem todoItem; // 카테고리명 - 목표 리스트 - 메인 컬러
  final void Function(String category, Color mainColor, Color subColor)
  onHeaderTap;

  final void Function({
    required String category, // 카테고리
    required SubTodo subTodo, // 카테고리에 속한 개별 목표 전체
    required Color mainColor,
    required Color subColor,
  })
  onItemTap;

  const Todo({
    super.key,
    required this.todoItem,
    required this.onHeaderTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = todoItem.mainColor;
    final Color subColor = getSubColor(mainColor);

    final doneCount = todoItem.subTodos.where((t) => t.isDone).length;
    final failCount = todoItem.subTodos.where((t) => !t.isDone).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TodoGroupHeader(
          title: todoItem.category,
          dotColor: mainColor,
          doneCount: doneCount,
          failCount: failCount,
          onTap: () {
            onHeaderTap(todoItem.category, mainColor, subColor);
          },
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todoItem.subTodos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final sub = todoItem.subTodos[index];
            return GestureDetector(
              onTap: () {
                onItemTap(
                  category: todoItem.category,
                  subTodo: sub,
                  mainColor: mainColor,
                  subColor: subColor,
                );
              },
              child: TodoItemCard(
                text: sub.goalTitle,
                isGroup: sub.isGroup,
                isDone: sub.isDone,
                subColor: subColor,
              ),
            );
          },
        ),
      ],
    );
  }
}
