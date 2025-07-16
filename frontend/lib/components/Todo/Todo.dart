import 'package:flutter/material.dart';
import '../Todo/TodoGroupHeader.dart';
import '../Todo/TodoList.dart';
import 'package:frontend/data.dart';

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
  final TodoItem todoItem;
  final void Function(String title, Color mainColor, Color subColor)
  onHeaderTap;

  final void Function({
    required String title,
    required SubTodo subTodo,
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
          title: todoItem.title,
          dotColor: mainColor,
          doneCount: doneCount,
          failCount: failCount,
          onTap: () {
            onHeaderTap(todoItem.title, mainColor, subColor);
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
                  title: todoItem.title,
                  subTodo: sub,
                  mainColor: mainColor,
                  subColor: subColor,
                );
              },
              child: TodoItemCard(
                text: sub.text,
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
