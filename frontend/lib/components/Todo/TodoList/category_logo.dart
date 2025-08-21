import 'package:flutter/material.dart';

class CategoryLogo extends StatefulWidget {
  final Color color;

  const CategoryLogo({required this.color, super.key});

  @override
  State<CategoryLogo> createState() => _StudyIconSpinnerState();
}

class _StudyIconSpinnerState extends State<CategoryLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _rotTurns;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotTurns = Tween(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));

    _ac.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _ac.forward(from: 0); // color가 바뀌면 애니메이션 다시 시작
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return RotationTransition(
          turns: _rotTurns,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _square(widget.color),
                  const SizedBox(width: 1),
                  _square(widget.color),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _square(widget.color),
                  const SizedBox(width: 1),
                  _square(widget.color),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _square(Color color) {
    return Container(width: 5, height: 5, color: color);
  }
}
