// import 'package:flutter/material.dart';
// import 'package:frontend/api/Todo/TodoItem.dart';
// import 'package:frontend/api/Todo/controller/category_controller.dart';
// import 'package:frontend/api/Todo/model/category_model.dart';
// import 'package:frontend/components/Todo/TodoColor.dart';
// import 'package:frontend/components/Todo/TodoDetail/AddCategory.dart';
// import 'package:frontend/components/Todo/TodoList/AddCategoryNew.dart';
// import 'package:frontend/components/Todo/TodoList/AddTodoNew.dart';
// import 'package:frontend/components/Todo/TodoList/TodoDetailNew.dart';
// import 'package:frontend/components/Todo/TodoList/categoryForm.dart';
// import 'package:frontend/constants/colors.dart';
// import 'package:frontend/components/Calendar/CustomMonthCalendar.dart';
// import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
// import 'package:frontend/components/Todo/Todo.dart';
// import 'package:frontend/components/Todo/TodoDetail/AddTodo.dart';
// import 'package:frontend/components/Todo/TodoDetail/TodoDetail.dart';
// import 'package:frontend/utils/auth_util.dart';

// class TodoPageView extends StatefulWidget {
//   const TodoPageView({super.key});

//   @override
//   State<TodoPageView> createState() => _MainPageViewState();
// }

// class _MainPageViewState extends State<TodoPageView> {
//   List<AllGoalsByCategory> todoList = [];
//   List<Category> categoryList = [];

//   @override
//   void initState() {
//     super.initState();
//     loadUserId();
//   }

//   String? userId;
//   int? selectedGoalId;

//   Future<void> loadUserId() async {
//     final uid = await getUserIdFromStorage();
//     if (uid == null) {
//       print('❌ 저장된 사용자 ID가 없습니다.');
//       return;
//     }

//     print("로딩됨");

//     setState(() {
//       userId = uid;
//     });
//     await loadCategories();
//     await loadGoalsForDate(selectedDate); // ✅ userId 로딩 후 목표 불러오기까지 연결
//   }

//   Future<void> loadCategories() async {
//     print('🟨 loadCategories 시작');
//     print(userId);
//     if (userId == null) return;
//     try {
//       final list = await CategoryController.fetchCategories(userId!);
//       print('✅ 응답 왔음');
//       setState(() {
//         categoryList = list;
//       });
//       print("📦 불러온 카테고리: ${list.map((c) => c.name).toList()}");
//     } catch (e) {
//       print("❌ 카테고리 불러오기 실패: $e");
//     }
//   }

//   Future<void> loadGoalsForDate(DateTime date) async {
//     if (userId == null) return;

//     try {
//       final formattedDate = date.toIso8601String().substring(0, 10);
//       List<AllGoalsByCategory> allItems = [];

//       for (final category in categoryList) {
//         final goals = await CategoryController.fetchGoalsByDate(
//           userId: userId!,
//           date: formattedDate,
//           categoryName: category.name,
//         );

//         final int colorIndex = (category.color ?? 1) - 1;
//         final Color mainColor =
//             mainColors[colorIndex.clamp(0, mainColors.length - 1)];
//         final Color subColor =
//             subColors[colorIndex.clamp(0, subColors.length - 1)];

//         final List<IndividualGoal> subTodos = goals.map((goal) {
//           return IndividualGoal(
//             goalId: goal.id,
//             goalTitle: goal.title,
//             isGroup: goal.isGroupGoal,
//             isDone: goal.completed,
//             isTimerRequired: goal.proofType == 'TIME',
//             isPhotoRequired: goal.proofType == 'IMAGE',
//             targetTime: goal.targetTime,
//           );
//         }).toList();

//         allItems.add(
//           AllGoalsByCategory(
//             colorIndex: colorIndex,
//             categoryIcon: category.icon,
//             categoryId: category.id,
//             categoryName: category.name,
//             goals: subTodos,
//           ),
//         );
//       }

//       setState(() {
//         todoList = allItems;
//       });
//     } catch (e) {
//       print('목표 불러오기 오류: $e');
//     }
//   }

//   DateTime selectedDate = DateTime.now(); // ✅ 선택된 날짜 저장

//   bool isMonthView = true;
//   bool isDetailVisible = false; //목표 추가 창 보이기
//   bool isDoneDetailVisible = false; //개별 목표 창 보기
//   bool isAddCategoryVisible = false;

//   //목표 추가 창 보이기
//   String selectedCategory = '';
//   Color selectedMainColor = Colors.grey;
//   Color selectedSubColor = Colors.grey;

//   //개별 목표 세부사항 내용 보이기 (위에랑 합쳐져야함)
//   String selectedGoalText = '';
//   bool isDone = false;
//   String selectedGroupType = '';
//   String selectedCertType = '';
//   int? selectedTargetTime;

//   void toggleView() {
//     setState(() {
//       isMonthView = !isMonthView;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
//             child: Column(
//               children: [
//                 CustomWeekCalendar(
//                   onDateSelected: (date) {
//                     setState(() {
//                       selectedDate = date;
//                       // API 연결 후: fetchGoalsByDate(userId, selectedDate);
//                     });
//                     loadGoalsForDate(date);
//                   },
//                 ),
//                 const SizedBox(height: 30),
//                 TodoDetailForm(
//                   initialTitle: '알고리즘 기초 2문제',
//                   initialVerification: const {'time'}, // 또는 {'photo'}
//                   onSubmit:
//                       ({required String title, required Set<String> types}) {},
//                 ),

//                 //CategorySection(),
//                 // AddCategoryForm(
//                 //   onSubmit:
//                 //       ({
//                 //         required title,
//                 //         required colorIndex,
//                 //         required types,
//                 //         required iconKey,
//                 //       }) {
//                 //         // 저장/전송 처리
//                 //         // print(title, color, types, iconKey);
//                 //       },
//                 // ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         for (final item in todoList)
//                           Todo(
//                             todoItem: item, // Todo : 카테고리와 해당 카테고리의 목표들
//                             onHeaderTap: (category, main, sub) {
//                               // 카테고리 클릭 -> 해당 카테고리의 목표 추가 시 넘어가는 항목
//                               setState(() {
//                                 selectedCategory = category; // 카테고리
//                                 selectedMainColor = main; // 메인 컬러
//                                 selectedSubColor = sub; // 서브 컬러
//                                 isDetailVisible = true;
//                                 isDoneDetailVisible = false;
//                                 isAddCategoryVisible = false;
//                               });
//                             },
//                             onItemTap: // 목표 클릭 -> 목표 세부사항 띄울때 넘어가는 항목들
//                                 ({
//                                   required String category,
//                                   required subTodo,
//                                   required Color mainColor,
//                                   required Color subColor,
//                                 }) {
//                                   setState(() {
//                                     selectedCategory = category;
//                                     selectedMainColor = mainColor;
//                                     selectedSubColor = subColor;
//                                     selectedGoalText = subTodo.goalTitle;
//                                     isDone = subTodo.isDone;
//                                     selectedGroupType = subTodo.isGroup
//                                         ? '그룹'
//                                         : '개인';
//                                     selectedCertType = subTodo.isTimerRequired
//                                         ? 'time'
//                                         : subTodo.isPhotoRequired
//                                         ? 'photo'
//                                         : '';
//                                     selectedGoalId = subTodo.goalId;
//                                     selectedTargetTime = subTodo.targetTime;
//                                     isDetailVisible = false;
//                                     isDoneDetailVisible = true;
//                                     isAddCategoryVisible = false;
//                                   });
//                                 },
//                           ),

//                         const SizedBox(height: 15),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: TextButton(
//                             onPressed: () {
//                               setState(() {
//                                 isAddCategoryVisible = true;
//                                 isDetailVisible = false;
//                                 isDoneDetailVisible = false;
//                               });
//                             },

//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.only(left: 10),
//                               minimumSize: Size(0, 0),
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                             child: Text(
//                               '➕ 카테고리 추가',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 60),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isDetailVisible || isDoneDetailVisible || isAddCategoryVisible)
//             Positioned.fill(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   setState(() {
//                     isDetailVisible = false;
//                     isDoneDetailVisible = false;
//                     isAddCategoryVisible = false;
//                   });
//                 },
//                 child: Container(), // 투명
//               ),
//             ),

//           if (isDetailVisible)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: AddTodo(
//                 category: selectedCategory,
//                 mainColor: selectedMainColor,
//                 subColor: selectedSubColor,
//                 onClose: () {
//                   setState(() {
//                     isDetailVisible = false;
//                   });
//                   loadGoalsForDate(selectedDate);
//                 },
//               ),
//             ),
//           if (isDoneDetailVisible)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,

//               child: TodoDetail(
//                 category: selectedCategory,
//                 group: selectedGroupType,
//                 goalText: selectedGoalText,
//                 done: isDone,
//                 certificationType: selectedCertType,
//                 mainColor: selectedMainColor,
//                 subColor: selectedSubColor,
//                 goalId: selectedGoalId!,
//                 targetTime: selectedTargetTime,
//                 onClose: () {
//                   setState(() {
//                     isDoneDetailVisible = false;
//                   });
//                   loadGoalsForDate(selectedDate);
//                 },
//               ),
//             ),
//           if (isAddCategoryVisible)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: AddCategoryUI(
//                 onClose: () async {
//                   setState(() {
//                     isAddCategoryVisible = false;
//                   });
//                   await loadCategories();
//                   await loadGoalsForDate(selectedDate);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
