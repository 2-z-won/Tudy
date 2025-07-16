import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/TodoItem.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';
import 'package:frontend/components/Todo/TodoDetail/AddCategory.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CustomMonthCalendar.dart';
import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
import 'package:frontend/components/Todo/Todo.dart';
import 'package:frontend/components/Todo/TodoDetail/AddTodo.dart';
import 'package:frontend/components/Todo/TodoDetail/TodoDetail.dart';

class TodoPageView extends StatefulWidget {
  const TodoPageView({super.key});

  @override
  State<TodoPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<TodoPageView> {
  List<TodoItem> todoList = [];

  Future<void> loadGoalsForDate(DateTime date) async {
    try {
      final userId = '1'; // TODO: 실제 로그인 유저 ID로 교체
      final formattedDate = date.toIso8601String().substring(
        0,
        10,
      ); // yyyy-MM-dd
      final goals = await CategoryController.fetchGoalsByDate(
        userId: userId,
        date: formattedDate,
      );

      // 변환: Goal → TodoItem
      final List<TodoItem> mapped = goals.map((goal) {
        final Color mainColor = Colors.blue;

        return TodoItem(
          category: goal.category.name,
          mainColor: mainColor,
          subTodos: [
            SubTodo(
              goalTitle: goal.title,
              isGroup: goal.isGroupGoal,
              isDone: goal.completed,
              isTimerRequired: false, // TODO: backend certType 필드 추가 시 반영
              isPhotoRequired: false,
            ),
          ],
        );
      }).toList();

      setState(() {
        todoList = mapped;
      });
    } catch (e) {
      print('목표 불러오기 오류: $e');
    }
  }

  DateTime selectedDate = DateTime.now(); // ✅ 선택된 날짜 저장

  bool isMonthView = true;
  bool isDetailVisible = false; //목표 추가 창 보이기
  bool isDoneDetailVisible = false; //개별 목표 창 보기
  bool isAddCategoryVisible = false;

  //목표 추가 창 보이기
  String selectedCategory = '';
  Color selectedMainColor = Colors.grey;
  Color selectedSubColor = Colors.grey;

  //개별 목표 세부사항 내용 보이기 (위에랑 합쳐져야함)
  String selectedGoalText = '';
  bool isDone = false;
  String selectedGroupType = '';
  String selectedCertType = '';

  void toggleView() {
    setState(() {
      isMonthView = !isMonthView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                // 상단 토글 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: toggleView,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // 텍스트 색상
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero, // 최소 크기 제거 (필요 시)
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isMonthView ? "Month 🟰" : "Week 🟰",
                        style: const TextStyle(
                          fontSize: 12,
                          color: SubTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ 달력 뷰: Month ↔ Week
                isMonthView
                    ? CustomMonthCalendar(
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                            // TODO: 해당 날짜 기준으로 todoList 갱신하기
                          });
                          loadGoalsForDate(date);
                        },
                      )
                    : CustomWeekCalendar(
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                            // API 연결 후: fetchGoalsByDate(userId, selectedDate);
                          });
                          loadGoalsForDate(date);
                        },
                      ),

                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final item in todoList)
                          Todo(
                            todoItem: item, // Todo : 카테고리와 해당 카테고리의 목표들
                            onHeaderTap: (category, main, sub) {
                              // 카테고리 클릭 -> 해당 카테고리의 목표 추가 시 넘어가는 항목
                              setState(() {
                                selectedCategory = category; // 카테고리
                                selectedMainColor = main; // 메인 컬러
                                selectedSubColor = sub; // 서브 컬러
                                isDetailVisible = true;
                                isDoneDetailVisible = false;
                                isAddCategoryVisible = false;
                              });
                            },
                            onItemTap: // 목표 클릭 -> 목표 세부사항 띄울때 넘어가는 항목들
                                ({
                                  required String category,
                                  required subTodo,
                                  required Color mainColor,
                                  required Color subColor,
                                }) {
                                  setState(() {
                                    selectedCategory = category;
                                    selectedMainColor = mainColor;
                                    selectedSubColor = subColor;
                                    selectedGoalText = subTodo.goalTitle;
                                    isDone = subTodo.isDone;
                                    selectedGroupType = subTodo.isGroup
                                        ? '그룹'
                                        : '개인';
                                    selectedCertType = subTodo.isTimerRequired
                                        ? 'time'
                                        : subTodo.isPhotoRequired
                                        ? 'photo'
                                        : '';
                                    isDetailVisible = false;
                                    isDoneDetailVisible = true;
                                    isAddCategoryVisible = false;
                                  });
                                },
                          ),

                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isAddCategoryVisible = true;
                                isDetailVisible = false;
                                isDoneDetailVisible = false;
                              });
                            },

                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(left: 10),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '➕ 카테고리 추가',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isDetailVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AddTodo(
                category: selectedCategory,
                mainColor: selectedMainColor,
                subColor: selectedSubColor,
                onClose: () {
                  setState(() {
                    isDetailVisible = false;
                  });
                },
              ),
            ),
          if (isDoneDetailVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TodoDetail(
                category: selectedCategory,
                group: selectedGroupType,
                goalText: selectedGoalText,
                done: isDone,
                certificationType: selectedCertType,
                mainColor: selectedMainColor,
                subColor: selectedSubColor,
                onClose: () {
                  setState(() {
                    isDoneDetailVisible = false;
                  });
                },
              ),
            ),
          if (isAddCategoryVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AddCategory(
                category: '', // 초기값 또는 선택값
                mainColor: Colors.grey,
                subColor: Colors.grey.shade100,
                onClose: () {
                  setState(() {
                    isAddCategoryVisible = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
