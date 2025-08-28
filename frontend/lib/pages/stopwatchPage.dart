import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/api/StopWatch/rank_controller.dart';
import 'package:frontend/api/Todo/TodoPageController.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/Todo/Todo.dart';
import 'package:frontend/api/Todo/model/allGoalByOneCategory.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/categoryForm.dart';
import 'package:frontend/components/Todo/TodoList/todoForm.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:frontend/api/StopWatch/stopwatch_controller.dart';
import 'package:get/get.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final StudyRankingController rankCtrl = Get.put(StudyRankingController());

  String? userId;

  final StudySessionController _sessionController = Get.put(
    StudySessionController(),
  );

  Timer? _timer;

  // ✅ 변경
  int _seconds = 0;
  bool _isRunning = false;

  // ✅ TodoSection 컨트롤러 준비
  final _todoCtrl = TodoSectionController();

  final _catCtrl = CategorySectionController();

  // ✅ 선택된 목표 표시용(링 색/제목)
  String? _selectedGoalTitle;
  Color? _selectedSubColor;
  int? selectedGoalId;
  Category? selectedCategory;
  bool _showCategoryPicker = false;

  final ctrl = Get.put(TodoPageController());

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final uid = await getUserIdFromStorage();
    if (uid == null) {
      debugPrint('❌ 저장된 사용자 ID가 없습니다.');
      return;
    }
    userId = uid; // ⬅️ 저장 (저장 시간 전송에 필요)
    await ctrl.init(uid); // 카테고리+목표 로드
    await rankCtrl.fetchAndStart();
  }

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

  Future<void> _stopTimer() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (selectedGoalId != null && userId != null) {
      await _sessionController.logStudyTime(
        userId: userId!,
        goalId: selectedGoalId!,
        seconds: _seconds,
      );

      // (선택) 진행률 새로고침
      await ctrl.loadGoalsForDate(ctrl.selectedDate.value);
    }
  }

  void _onGoalTap({required Goal goal}) {
    final idx = (goal.category.color - 1).clamp(0, subColors.length - 1);
    setState(() {
      selectedGoalId = goal.id;
      _selectedGoalTitle = goal.title;
      _selectedSubColor = subColors[idx];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Obx(() {
                if (rankCtrl.error.isNotEmpty) {
                  return Text(
                    '랭킹 불러오기 실패',
                    key: const ValueKey('error'),
                    style: const TextStyle(fontSize: 16),
                  );
                }
                final cur = rankCtrl.current;
                final rank = rankCtrl.currentRank;
                final text = (cur == null)
                    ? '🏆 순위 없음'
                    : '🏆 $rank등: ${cur.major} (${cur.value})';
                return Text(
                  text,
                  key: ValueKey(text),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
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
                  border: Border.all(
                    color: _selectedSubColor ?? const Color(0xFFF2E9DA),
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedGoalTitle ?? '목표 선택',
                      style: TextStyle(fontSize: 16),
                    ),
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
              child: Obx(() {
                final categories = ctrl.categories.toList();

                // 선택된 카테고리 기준으로 Todo 데이터 필터링
                final List<AllGoalsByOneCategory> filtered =
                    (selectedCategory == null)
                    ? ctrl.allGoalsByAllCategory
                          .toList() // ← All(전체)
                    : ctrl.allGoalsByAllCategory
                          .where((g) => g.category.id == selectedCategory!.id)
                          .toList();

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _showCategoryPicker
                      // ① 카테고리 선택 화면
                      ? CategorySection(
                          key: const ValueKey('category'),
                          controller: _catCtrl,
                          categories: categories,
                          showAddButton: false, // 스톱워치에선 + 숨김
                          onAddCategory: null,
                          onAllSelected: () {
                            setState(() {
                              selectedCategory = null;
                              _showCategoryPicker = false;
                            });
                          },
                          onCategorySelected: (c) {
                            setState(() {
                              selectedCategory = c;
                              _showCategoryPicker = false;
                            });
                          },
                        )
                      // ② Todo 목록 화면 (선택 없으면 All)
                      : TodoSection(
                          controller: _todoCtrl,
                          onAddTodoTap: () {},
                          onTodoCardTap: _onGoalTap, // ({required Goal goal})
                          allGoalsByAllCategory: filtered, // All 또는 선택된 카테고리
                          selectedCategory: selectedCategory,
                          showAddButton: false, // 스톱워치에선 + 숨김
                          onCategoryListType: () => setState(() {
                            _showCategoryPicker = true; // 카테고리 피커 열기
                          }),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
