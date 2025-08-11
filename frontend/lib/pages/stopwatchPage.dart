import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/components/Todo/Todo.dart';
import 'package:frontend/api/Todo/TodoItem.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:frontend/api/StopWatch/stopwatch_controller.dart';
import 'package:get/get.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  List<TodoItem> todoList = [];
  List<Category> categoryList = [];
  String? userId;
  DateTime selectedDate = DateTime.now();

  final StudySessionController _sessionController = Get.put(
    StudySessionController(),
  );

  Color _selectedSubColor = const Color(0xFFF8BBD0); // 기본 테두리 색
  String _selectedGoalTitle = '알고리즘 공부하기'; // 기본 텍스트

  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  int? _selectedGoalId;

  String get _formattedTime {
    final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (_selectedGoalId != null && userId != null) {
      await _sessionController.logStudyTime(
        userId: userId!,
        goalId: _selectedGoalId!,
        seconds: _seconds,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage();
    if (uid == null) return;

    setState(() {
      userId = uid;
    });
    await loadCategories();
    await loadGoalsForDate(selectedDate);
  }

  Future<void> loadCategories() async {
    if (userId == null) return;
    try {
      final list = await CategoryController.fetchCategories(userId!);
      setState(() {
        categoryList = list;
      });
    } catch (e) {
      print("카테고리 로딩 실패: $e");
    }
  }

  Future<void> loadGoalsForDate(DateTime date) async {
    if (userId == null) return;
    try {
      final formattedDate = date.toIso8601String().substring(0, 10);
      List<TodoItem> allItems = [];

      for (final category in categoryList) {
        final goals = await CategoryController.fetchGoalsByDate(
          userId: userId!,
          date: formattedDate,
          categoryName: category.name,
        );

        final int colorIndex = (category.color ?? 1) - 1;
        final Color mainColor =
            mainColors[colorIndex.clamp(0, mainColors.length - 1)];
        final Color subColor =
            subColors[colorIndex.clamp(0, subColors.length - 1)];

        final List<SubTodo> subTodos = goals.map((goal) {
          return SubTodo(
            goalId: goal.id,
            goalTitle: goal.title,
            isGroup: goal.isGroupGoal,
            isDone: goal.completed,
            isTimerRequired: goal.proofType == 'TIME',
            isPhotoRequired: goal.proofType == 'PHOTO',
          );
        }).toList();

        allItems.add(
          TodoItem(
            category: category.name,
            mainColor: mainColor,
            subColor: subColor,
            subTodos: subTodos,
          ),
        );
      }

      setState(() {
        todoList = allItems;
      });
    } catch (e) {
      print('목표 불러오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '🏆 1st: 정보의생명공학대학', //일단 텍스트 처리해놨어
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: _toggleTimer,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2E9DA).withOpacity(0.5),
                      spreadRadius: 10,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedSubColor, width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_selectedGoalTitle, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? 'STOP' : 'START',
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  for (final item in todoList)
                    Todo(
                      todoItem: item,
                      onHeaderTap: (_, __, ___) {}, // 필요 없으면 빈 함수
                      onItemTap:
                          ({
                            required category,
                            required subTodo,
                            required mainColor,
                            required subColor,
                          }) async {
                            await _sessionController.fetchAccumulatedTime(
                              subTodo.goalId,
                            );

                            setState(() {
                              _selectedGoalId = subTodo.goalId;
                              _selectedSubColor = subColor;
                              _selectedGoalTitle = subTodo.goalTitle;
                              _seconds = _sessionController
                                  .accumulatedTime
                                  .value
                                  .inSeconds;
                            });
                          },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
