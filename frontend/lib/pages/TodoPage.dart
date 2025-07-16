import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/Calendar/CustomMonthCalendar.dart';
import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
import 'package:frontend/components/Todo/Todo.dart';
import 'package:frontend/components/Todo/TodoDetail/AddTodo.dart';
import 'package:frontend/components/Todo/TodoDetail/TodoDetail.dart';
import 'package:frontend/data.dart';

class TodoPageView extends StatefulWidget {
  const TodoPageView({super.key});

  @override
  State<TodoPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<TodoPageView> {
  bool isMonthView = true;
  bool isDetailVisible = false; //목표 추가 창 보이기
  bool isDoneDetailVisible = false; //개별 목표 창 보기

  //목표 추가 창 보이기
  String selectedTitle = '';
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
                    ? const CustomMonthCalendar()
                    : const CustomWeekCalendar(),

                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final item in todoList)
                          Todo(
                            todoItem: item,
                            onHeaderTap: (title, main, sub) {
                              setState(() {
                                selectedTitle = title;
                                selectedMainColor = main;
                                selectedSubColor = sub;
                                isDetailVisible = true;
                                isDoneDetailVisible = false;
                              });
                            },
                            onItemTap:
                                ({
                                  required String title,
                                  required subTodo,
                                  required Color mainColor,
                                  required Color subColor,
                                }) {
                                  setState(() {
                                    selectedTitle = title;
                                    selectedMainColor = mainColor;
                                    selectedSubColor = subColor;
                                    selectedGoalText = subTodo.text;
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
                                  });
                                },
                          ),

                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
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
                title: selectedTitle,
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
                title: selectedTitle,
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
        ],
      ),
    );
  }
}
