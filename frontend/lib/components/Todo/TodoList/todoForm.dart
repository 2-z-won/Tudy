import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/model/allGoalByOneCategory.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/category_logo.dart';
import 'package:frontend/components/Todo/TodoList/component/TodoList_component.dart';
import 'package:frontend/components/Todo/TodoList/component/pop_transitions.dart';
import 'package:frontend/constants/colors.dart';

class TodoSectionController {
  Future<void> Function()? playExit;
}

class TodoSection extends StatefulWidget {
  const TodoSection({
    super.key,

    this.onCategoryAddTap,
    this.controller,
    this.onAddTodoTap,
    this.onTodoCardTap,
    required this.allGoalsByAllCategory,
    this.selectedCategory,
    this.showAddButton = true,
    this.onCategoryListType,
  });
  final VoidCallback? onCategoryAddTap;
  final TodoSectionController? controller;
  final VoidCallback? onAddTodoTap;
  final VoidCallback? onCategoryListType;
  final void Function({required Goal goal})? onTodoCardTap;

  final List<AllGoalsByOneCategory> allGoalsByAllCategory;
  final Category? selectedCategory;
  final bool showAddButton;

  @override
  State<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection>
    with TickerProviderStateMixin {
  late final AnimationController _inCtrl;
  late final AnimationController _outCtrl;

  // ⬇️ 여기만 변경
  List<Animation<double>> _inAnims = const [];
  List<Animation<double>> _outAnims = const [];

  @override
  void initState() {
    super.initState();
    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _outCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _inCtrl.forward());
    widget.controller?.playExit = playExit;
  }

  @override
  void dispose() {
    _inCtrl.dispose();
    _outCtrl.dispose();
    super.dispose();
  }

  Future<void> playExit() async {
    // 등장 중이면 멈춰도 되고, 자연스럽게 퇴장만 재생
    await _outCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant TodoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCount = oldWidget.allGoalsByAllCategory.fold<int>(
      0,
      (s, g) => s + g.goals.length,
    );
    final newCount = widget.allGoalsByAllCategory.fold<int>(
      0,
      (s, g) => s + g.goals.length,
    );
    if (oldCount != newCount) _inCtrl.forward(from: 0);
  }

  void _buildInAnims() {
    _inAnims = Stagger.by(
      _inCtrl,
      count: 1 /*제목 제외*/ + widget.allGoalsByAllCategory.length + 1 /*+추가*/,
      step: .12,
      span: .45,
      curve: Curves.easeOut,
    );
  }

  void _buildAnims(int itemCount) {
    final count = 1 /*제목*/ + itemCount + 1 /*+추가*/;
    _inAnims = Stagger.by(
      _inCtrl,
      count: count,
      step: .12,
      span: .45,
      curve: Curves.easeOut,
    );
    _outAnims = Stagger.by(
      _outCtrl,
      count: count,
      step: .12,
      span: .45,
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 전체 카드 수
    final itemCount = widget.allGoalsByAllCategory.fold<int>(
      0,
      (sum, g) => sum + g.goals.length,
    );
    _buildAnims(itemCount);

    // 카테고리별 누적 오프셋 (애니 인덱스 계산용)
    int base = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 제목: 팝아웃만 적용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            children: [
              const Text(
                'Todo',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onCategoryListType,
                child: Row(
                  children: [
                    Text(
                      widget.selectedCategory != null
                          ? widget.selectedCategory!.name
                          : "All",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "GmarketSans",
                        fontWeight: FontWeight.w700,
                        color: TextColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    CategoryLogo(
                      color: widget.selectedCategory != null
                          ? mainColors[(widget.selectedCategory!.color - 1)
                                .clamp(0, mainColors.length - 1)]
                          : TextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).popOut(_outAnims[0]),
        const SizedBox(height: 5),

        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final allGoalsByCategory
                    in widget.allGoalsByAllCategory) ...[
                  Builder(
                    builder: (_) {
                      final idx = (allGoalsByCategory.category.color - 1).clamp(
                        0,
                        subColors.length - 1,
                      );
                      final Color subColor = subColors[idx];

                      final list = ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allGoalsByCategory.goals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 7),
                        itemBuilder: (context, index) {
                          final goal =
                              allGoalsByCategory.goals[index]; // <-- Goal

                          return GestureDetector(
                            onTap: () => widget.onTodoCardTap?.call(goal: goal),
                            child: TodoListCard(
                              bgColor: subColor,
                              categoryIcon: allGoalsByCategory
                                  .category
                                  .icon, // e.g. "☕" (nullable면 기본값 넣어도 OK)
                              text: goal.title,
                              progress: goal.completed
                                  ? "Complete"
                                  : "${(goal.timeProgressRatio * 100).round()}%",
                              isDone: goal.completed,
                            ),
                          );
                        },
                      );

                      return list;
                    },
                  ),
                ],

                if (widget.showAddButton) ...[
                  AddTodoCard(onTap: widget.onAddTodoTap)
                      .popIn(_inAnims[1 + itemCount])
                      .popOut(_outAnims[1 + itemCount]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TodoListCard extends StatelessWidget {
  final Color bgColor;
  final String categoryIcon;
  final String text;
  final String progress;
  final bool isDone;

  const TodoListCard({
    required this.bgColor,
    required this.categoryIcon,
    required this.text,
    required this.progress,
    required this.isDone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDone ? bgColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bgColor, width: 3),
        boxShadow: [dropShadow],
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 15),
        child: _TodoListCardRow(),
      ),
    );
  }
}

class _TodoListCardRow extends StatelessWidget {
  const _TodoListCardRow();

  @override
  Widget build(BuildContext context) {
    // 주의: 위젯 트리 구조/텍스트 내용은 원본 유지 요구에 따라 변경하지 않았습니다.
    final parent = context.findAncestorWidgetOfExactType<TodoListCard>()!;
    final isDone = parent.isDone;
    final bgColor = parent.bgColor;
    final text = parent.text;
    final progress = parent.progress;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${parent.categoryIcon} $text",
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const Spacer(),
        DottedLine(
          direction: Axis.vertical,
          dashLength: 5,
          dashGapLength: 2,
          lineThickness: 1,
          dashColor: isDone ? Colors.white : bgColor,
        ),
        SizedBox(
          width: 77,
          child: Text(
            textAlign: TextAlign.center,
            isDone ? "Complete" : progress,
            style: TextStyle(
              color: isDone ? Colors.white : bgColor,
              fontSize: isDone ? 11 : 12,
              fontFamily: "GmarketSans",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// ➕ 플러스(추가) 카드
class AddTodoCard extends StatelessWidget {
  final VoidCallback? onTap;
  const AddTodoCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF2E9DA).withOpacity(0.6),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFF2E9DA),
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

class _TodoListData {
  final String title;
  final bool isDone;
  final Color mainColor; // 테두리/텍스트
  final Color subColor; // 완료 시 배경
  final String progress; // "96%" 등
  final String icon;
  _TodoListData({
    required this.title,
    required this.isDone,
    required this.mainColor,
    required this.subColor,
    required this.progress,
    required this.icon,
  });
}
