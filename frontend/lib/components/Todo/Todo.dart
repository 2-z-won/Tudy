import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/TodoItem.dart';
import '../Todo/TodoGroupHeader.dart';
import '../Todo/TodoList.dart';
// ignore: unused_import
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  final void Function(String category, Color mainColor, Color subColor)
  onHeaderTap;

  final void Function({
    required String category,
    required SubTodo subTodo,
    required Color mainColor,
    required Color subColor,
  })
  onItemTap;

  final Future<bool> Function(int goalId)? onDelete;

  const Todo({
    super.key,
    required this.todoItem,
    required this.onHeaderTap,
    required this.onItemTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = todoItem.mainColor;
    final Color subColor = todoItem.subColor;

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
        todoItem.subTodos.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Center(
                  child: Text(
                    '아직 등록된 목표가 없습니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todoItem.subTodos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final sub = todoItem.subTodos[index];

                  return Slidable(
                    key: ValueKey('goal_${sub.goalId}_${todoItem.category}'),
                    closeOnScroll: true,
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.18,
                      dismissible: DismissiblePane(
                        onDismissed: () async {
                          //확인 다이얼로그
                          final ok =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('삭제할까요?'),
                                  content: Text(
                                    '「${sub.goalTitle}」을(를) 삭제합니다.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!ok) {
                            Slidable.of(context)?.close(); // 취소 시 다시 닫기
                            return;
                          }

                          var success = true;
                          if (onDelete != null) {
                            success = await onDelete!(sub.goalId);
                          }
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('삭제 실패. 다시 시도해 주세요.'),
                              ),
                            );
                            Slidable.of(context)?.close();
                            return;
                          }
                        },
                      ),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('삭제할까요?'),
                                    content: Text(
                                      '「${sub.goalTitle}」을(를) 삭제합니다.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (!ok) return;

                            var success = true;
                            if (onDelete != null)
                              success = await onDelete!(sub.goalId);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('삭제 실패. 다시 시도해 주세요.'),
                                ),
                              );
                              Slidable.of(context)?.close();
                              return;
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () => onItemTap(
                        category: todoItem.category,
                        subTodo: sub,
                        mainColor: mainColor,
                        subColor: subColor,
                      ),
                      child: TodoItemCard(
                        text: sub.goalTitle,
                        isGroup: sub.isGroup,
                        isDone: sub.isDone,
                        subColor: subColor,
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 8),
      ],
    );
  }
}
