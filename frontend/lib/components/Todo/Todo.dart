// import 'package:flutter/material.dart';
// import 'package:frontend/api/Todo/TodoItem.dart';
// import '../Todo/TodoGroupHeader.dart';
// import '../Todo/TodoList.dart';
// import 'package:frontend/components/Todo/TodoColor.dart';

// class Todo extends StatelessWidget {
//   final AllGoalsByCategory todoItem; // 카테고리명 - 목표 리스트 - 메인 컬러
//   final void Function(String category, Color mainColor, Color subColor)
//   onHeaderTap;

//   final void Function({
//     required String category, // 카테고리
//     required IndividualGoal subTodo, // 카테고리에 속한 개별 목표 전체
//     required Color mainColor,
//     required Color subColor,
//   })
//   onItemTap;

//   const Todo({
//     super.key,
//     required this.todoItem,
//     required this.onHeaderTap,
//     required this.onItemTap,
//   });

//   @override
//   Widget build(BuildContext context) {

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TodoGroupHeader(
//           title: todoItem.category,
//           dotColor: mainColor,
//           doneCount: doneCount,
//           failCount: failCount,
//           onTap: () {
//             onHeaderTap(todoItem.category, mainColor, subColor);
//           },
//         ),
//         todoItem.subTodos.isEmpty
//             ? Padding(
//                 padding: const EdgeInsets.only(left: 10, bottom: 10),
//                 child: Center(
//                   child: Text(
//                     '아직 등록된 목표가 없습니다.',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ),
//               )
//             : ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: todoItem.subTodos.length,
//                 separatorBuilder: (context, index) => const SizedBox(height: 6),
//                 itemBuilder: (context, index) {
//                   final sub = todoItem.subTodos[index];
//                   return GestureDetector(
//                     onTap: () {
//                       onItemTap(
//                         category: todoItem.category,
//                         subTodo: sub,
//                         mainColor: mainColor,
//                         subColor: subColor,
//                       );
//                     },
//                     child: TodoItemCard(
//                       text: sub.goalTitle,
//                       isGroup: sub.isGroup,
//                       isDone: sub.isDone,
//                       subColor: subColor,
//                     ),
//                   );
//                 },
//               ),
//         SizedBox(height: 8),
//       ],
//     );
//   }
// }
