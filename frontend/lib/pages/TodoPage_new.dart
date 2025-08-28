import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:frontend/api/Todo/model/allGoalByOneCategory.dart';
import 'package:frontend/api/Todo/TodoPageController.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/AddCategoryNew.dart';
import 'package:frontend/components/Todo/TodoList/AddTodoNew.dart';
import 'package:frontend/components/Todo/TodoList/TodoDetailNew.dart';
import 'package:frontend/components/Todo/TodoList/categoryForm.dart';
import 'package:frontend/components/Todo/TodoList/component/TodoList_component.dart';
import 'package:frontend/components/Todo/TodoList/todoForm.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';

class NewTodoPageView extends StatefulWidget {
  const NewTodoPageView({super.key});

  @override
  State<NewTodoPageView> createState() => _NewTodoPageViewState();
}

enum _InnerPane { todo, addCategory }

enum _OuterPane { main, addTodo, todoDetail }

class _NewTodoPageViewState extends State<NewTodoPageView> {
  final ctrl = Get.put(TodoPageController());
  final _catCtrl = CategorySectionController();

  String? userId;
  int? selectedGoalId;
  Category? selectedCategory;
  Goal? _detailGoal;

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
    await ctrl.init(uid); // ← 이 한 줄이 categories + goals까지 로드
  }
  // ========================================= api 경계선

  final _todoCtrl = TodoSectionController();
  final _todoDetailCtrl = TodoDetailController();

  _InnerPane _inner = _InnerPane.todo;
  _OuterPane _outer = _OuterPane.main;

  Future<void> _openAddCategory() async {
    // 1) TodoSection 내부 요소들이 왼쪽으로 순차 퇴장
    if (_todoCtrl.playExit != null) {
      await _todoCtrl.playExit!();
    }
    if (!mounted) return;

    // 2) 자리를 AddCategoryForm으로 교체 (오른쪽에서 슬라이드 인)
    setState(() => _inner = _InnerPane.addCategory);
  }

  Future<void> _openAddTodo() async {
    final exits = <Future<void>>[];
    if (_todoCtrl.playExit != null) exits.add(_todoCtrl.playExit!());
    if (_catCtrl.playExit != null) exits.add(_catCtrl.playExit!());

    // 2) 둘이 다 끝날 때까지 함께 기다림
    if (exits.isNotEmpty) await Future.wait(exits);

    if (!mounted) return;

    // 3) 그 다음에 AddTodo로 전환
    setState(() => _outer = _OuterPane.addTodo);
  }

  void _handleTodoTap({required Goal goal}) async {
    selectedGoalId = goal.id;
    await _openTodoDetail(goal);
  }

  Future<void> _openTodoDetail(Goal goal) async {
    final exits = <Future<void>>[];
    if (_todoCtrl.playExit != null) exits.add(_todoCtrl.playExit!());
    if (_catCtrl.playExit != null) exits.add(_catCtrl.playExit!());
    if (exits.isNotEmpty) await Future.wait(exits);

    if (!mounted) return;

    setState(() {
      _outer = _OuterPane.todoDetail;
      _detailGoal = goal; // ✅ Goal 보관
    });
  }

  void _backToTodo() {
    // AddCategoryForm 안에서 자체 퇴장 애니메이션을 끝내고 호출됨
    setState(() {
      _outer = _OuterPane.main; // 전체는 메인 복귀
      _inner = _InnerPane.todo; // 아래는 Todo 리스트 복귀
    });
    // TodoSection은 새로 빌드되면서 기존처럼 등장 애니메이션이 자동 재생됨
  }

  Future<void> _closeTodoDetail() async {
    if (_todoDetailCtrl.playExit != null) {
      await _todoDetailCtrl.playExit!();
    }
    if (!mounted) return;
    setState(() {
      _outer = _OuterPane.main;
      _inner = _InnerPane.todo;
    });
  }

  DateTime selectedDate = DateTime.now();

  bool showTodoSection = true;

  @override
  Widget build(BuildContext context) {
    final Widget bottomPane = (_inner == _InnerPane.todo)
        ? Obx(() {
            final List<AllGoalsByOneCategory> filtered =
                (selectedCategory == null)
                ? ctrl.allGoalsByAllCategory.toList()
                : ctrl.allGoalsByAllCategory
                      .where((t) => t.category.id == selectedCategory!.id)
                      .toList();

            return TodoSection(
              controller: _todoCtrl,
              onAddTodoTap: _openAddTodo,
              onTodoCardTap: _handleTodoTap,
              allGoalsByAllCategory: filtered,
              selectedCategory: selectedCategory,
            );
          })
        : AddCategoryForm(
            onExit: _backToTodo,
            onSubmit: ({required String title}) async {
              // 폼에서 생성 완료 → 여기서는 목록만 새로고침
              await ctrl.loadCategories();
              await ctrl.loadGoalsForDate(ctrl.selectedDate.value);
              _backToTodo();
            },
          );

    final Widget mainPane = Column(
      children: [
        Obx(() {
          final _ = ctrl.categories.length;

          return CategorySection(
            controller: _catCtrl,
            categories: ctrl.categories,
            onAddCategory: _openAddCategory,
            showAddButton: _inner == _InnerPane.todo,
            onAllSelected: () async {
              setState(() {
                selectedCategory = null; // All
              });
              // 모든 카테고리 목표 로딩
              await ctrl.loadGoalsByCategory(null);
            },
            onCategorySelected: (c) async {
              setState(() {
                if (selectedCategory?.id == c.id) {
                  selectedCategory = null; // 같은 걸 다시 누르면 All
                } else {
                  selectedCategory = c;
                }
              });
              // 선택된 카테고리 목표 로딩
              await ctrl.loadGoalsByCategory(selectedCategory?.name);
            },
          );
        }),
        // ---- 안쪽 스위처: 아래 영역만 교체 ----
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter, // 상단 고정
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, anim) {
            final offsetIn = Tween<Offset>(
              begin: const Offset(0.10, 0),
              end: Offset.zero,
            ).animate(anim);
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(position: offsetIn, child: child),
            );
          },
          child: KeyedSubtree(key: ValueKey(_inner), child: bottomPane),
        ),
      ],
    );

    final Widget outerChild = (_outer == _OuterPane.main)
        ? mainPane
        : (_outer == _OuterPane.addTodo)
        ? AddTodoForm(
            categoryName: selectedCategory?.name ?? "",
            categoryColor:
                mainColors[((selectedCategory?.color ?? 1) - 1).clamp(
                  0,
                  mainColors.length - 1,
                )],
            onExit: _backToTodo,
            onSubmit: ({required title, required Set<String> types}) async {
              await ctrl.loadGoalsForDate(ctrl.selectedDate.value);
              _backToTodo();
            },
          )
        : TodoDetailForm(
            controller: _todoDetailCtrl,
            goal: _detailGoal!, // ✅ 여기!
            onExit: _closeTodoDetail,
            onSubmit: ({required String title, required Set<String> types}) {
              _backToTodo();
            },
          );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
        child: Column(
          children: [
            CustomWeekCalendar(onDateSelected: (date) => ctrl.changeDate(date)),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, anim) {
                final offsetIn = Tween<Offset>(
                  begin: const Offset(0.10, 0),
                  end: Offset.zero,
                ).animate(anim);
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: offsetIn, child: child),
                );
              },
              child: KeyedSubtree(key: ValueKey(_outer), child: outerChild),
            ),
          ],
        ),
      ),
    );
  }
}
