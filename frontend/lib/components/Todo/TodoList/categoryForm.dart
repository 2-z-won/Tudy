import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/component/pop_transitions.dart';
import 'package:frontend/constants/colors.dart';

class CategorySectionController {
  Future<void> Function()? playExit;
}

class CategorySection extends StatefulWidget {
  final VoidCallback? onAddCategory;
  final bool showAddButton;
  final CategorySectionController? controller;
  final List<Category> categories;
  final void Function(Category)? onCategorySelected;
  final VoidCallback onAllSelected;

  const CategorySection({
    super.key,
    this.onAddCategory,
    this.showAddButton = true,
    this.controller,
    required this.categories,
    required this.onCategorySelected,
    required this.onAllSelected,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection>
    with TickerProviderStateMixin {
  late final AnimationController _inCtrl;
  late List<Animation<double>> _inAnims;

  late final AnimationController _outCtrl;
  late List<Animation<double>> _outAnims;

  @override
  void initState() {
    super.initState();

    final itemCount =
        1 // ✅ All
        +
        widget.categories.length +
        (widget.showAddButton ? 1 : 0); // + 버튼

    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // 천천히
    );

    // ✅ 안전한 스태거 유틸 사용: t ∈ [0,1] 보장
    _inAnims = Stagger.by(
      _inCtrl,
      count: itemCount == 0 ? 1 : itemCount,
      step: .12,
      span: .45,
      curve: Curves.easeOut,
    );

    // 화면 그려진 뒤 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _inCtrl.forward());

    _outCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _outAnims = Stagger.by(
      _outCtrl,
      count: 2, // [제목, 카드1, 카드2, +추가]
      step: .12, // 제목 먼저 → 카드1 → 카드2 → +추가
      span: .45,
      curve: Curves.easeIn,
    );

    widget.controller?.playExit = playExit;
  }

  @override
  void didUpdateWidget(covariant CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔁 목록 길이/버튼 표시가 바뀌면 inAnims 재생성 (등장 애니가 새 데이터에 맞게)
    final itemCount =
        1 + widget.categories.length + (widget.showAddButton ? 1 : 0);
    _inAnims = Stagger.by(
      _inCtrl,
      count: itemCount == 0 ? 1 : itemCount,
      step: .12,
      span: .45,
      curve: Curves.easeOut,
    );
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
  Widget build(BuildContext context) {
    // 카드들 정의 (애니메이션만 감쌈)
    final cards = <Widget>[];
    var animIdx = 0;

    cards.add(
      AllCategoryCard(
        onTap: widget.onAllSelected, // ← 콜백 (null이어도 OK)
      ).popIn(_inAnims[animIdx++]),
    );
    cards.add(const SizedBox(width: 7));

    for (var i = 0; i < widget.categories.length; i++) {
      final c = widget.categories[i];
      final colorIndex = (c.color - 1).clamp(0, mainColors.length - 1);
      final mainColor = mainColors[colorIndex];

      cards.add(
        CategoryCard(
          title: c.name,
          doneCount: 0,
          failCount: 0,
          color: mainColor,
          onTap: () => widget.onCategorySelected?.call(c),
        ).popIn(_inAnims[animIdx++]),
      );
      cards.add(const SizedBox(width: 7));
    }
    if (widget.showAddButton) {
      cards.add(
        AnimatedAddButton(
          visible: true,
          onTap: () => widget.onAddCategory?.call(),
        ).popIn(_inAnims[animIdx++]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontFamily: "GmarketSans",
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ).popOut(_outAnims[0]),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: SizedBox(
            height: 114,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 4),
                ...cards,
                const SizedBox(width: 4),
              ],
            ),
          ),
        ).popOut(_outAnims[1]),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ---------------- 카드들은 그대로 ----------------

// 카테고리 카드
class CategoryCard extends StatelessWidget {
  final String title;
  final int doneCount;
  final int failCount;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CategoryCard({
    super.key,
    required this.title,
    required this.doneCount,
    required this.failCount,
    required this.color,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 120,
        height: 115,
        padding: const EdgeInsets.fromLTRB(13, 13, 12, 10),
        decoration: BoxDecoration(
          color: color,
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  Text(
                    ' $doneCount | ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: "GmarketSans",
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Icon(Icons.close, size: 14, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    ' $failCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: "GmarketSans",
                      fontWeight: FontWeight.w300,
                    ),
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

class AllCategoryCard extends StatelessWidget {
  final VoidCallback? onTap;
  const AllCategoryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 115,
        padding: const EdgeInsets.fromLTRB(13, 13, 12, 10),
        decoration: BoxDecoration(
          color: TextColor,
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
          child: Text(
            'All',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: "GmarketSans",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// ➕ 플러스(추가) 카드
class AddCategoryCard extends StatelessWidget {
  final VoidCallback? onTap;
  const AddCategoryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 115,
        height: 115,
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

class AnimatedAddButton extends StatelessWidget {
  final bool visible;
  final VoidCallback? onTap;

  const AnimatedAddButton({super.key, required this.visible, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 보일 때는 고정 크기(115x115)의 + 카드, 숨길 때는 0x0
    final child = visible
        ? SizedBox(
            width: 115,
            height: 115,
            child: AddCategoryCard(onTap: onTap),
          )
        : const SizedBox.shrink(key: ValueKey('add-empty'));

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInCubic, // 🔥 “빡!” 팝인 느낌
        switchOutCurve: Curves.easeInCubic, // ⬅️ 부드럽게 줄어들며 사라짐
        transitionBuilder: (child, anim) {
          // 들어올 땐 0.6→1.0, 나갈 땐 1.0→0.6 (자동으로 반대로 재생)
          final scale = Tween<double>(begin: 0.2, end: 1.0).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: child,
      ),
    );
  }
}
