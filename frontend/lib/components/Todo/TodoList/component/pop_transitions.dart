import 'package:flutter/material.dart';

/// 공통 팝인: Fade + Slide(from) + Scale(0.92→1.0, easeOutBack)
class PopInTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset from; // 기본: 아래서 8% 떠오름
  final double fromScale; // 기본: 0.92 → 1.0
  final Curve slideCurve;
  final Curve scaleCurve;
  final Curve opacityCurve;

  const PopInTransition({
    super.key,
    required this.animation,
    required this.child,
    this.from = const Offset(0, .08),
    this.fromScale = .92,
    this.slideCurve = Curves.easeOut,
    this.scaleCurve = Curves.easeOutBack,
    this.opacityCurve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: animation, curve: opacityCurve);
    final slide = Tween<Offset>(
      begin: from,
      end: Offset.zero,
    ).chain(CurveTween(curve: slideCurve)).animate(animation);
    final scale = Tween<double>(
      begin: fromScale,
      end: 1.0,
    ).chain(CurveTween(curve: scaleCurve)).animate(animation);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(scale: scale, child: child),
      ),
    );
  }
}

/// 공통 팝아웃: Slide(to) + FadeOut
class PopOutSlideFade extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset to; // 기본: 왼쪽으로 빠짐
  final Curve curve;

  const PopOutSlideFade({
    super.key,
    required this.animation,
    required this.child,
    this.to = const Offset(-0.8, 0),
    this.curve = Curves.easeIn,
  });

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: Offset.zero,
      end: to,
    ).chain(CurveTween(curve: curve)).animate(animation);
    final fade = Tween<double>(begin: 1, end: 0).animate(animation);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// 스태거 유틸: Interval 분배 + 안전 클램프
class Stagger {
  /// count개 애니메이션을 [0,1] 구간에 고르게 분배
  static List<Animation<double>> by(
    AnimationController ctrl, {
    required int count,
    double step = .12,
    double span = .45,
    Curve curve = Curves.easeOut,
  }) {
    assert(count > 0);
    const eps = 1e-6; // t 범위 안전장치
    final list = <Animation<double>>[];

    for (var i = 0; i < count; i++) {
      final start = (i * step).clamp(0.0, 1.0 - eps);
      final end = (start + span).clamp(0.0, 1.0);
      list.add(
        CurvedAnimation(
          parent: ctrl,
          curve: Interval(start, end, curve: curve),
        ),
      );
    }
    return list;
  }
}

/// 마운트 때 자동으로 순차등장하는 빌더 (컨트롤러까지 내장)
class StaggeredAppear extends StatefulWidget {
  final int count;
  final Duration duration;
  final double step;
  final double span;
  final Curve curve;
  final bool autoplay;
  final Widget Function(BuildContext, Animation<double>, int) builder;

  const StaggeredAppear({
    super.key,
    required this.count,
    required this.builder,
    this.duration = const Duration(milliseconds: 1200),
    this.step = .12,
    this.span = .45,
    this.curve = Curves.easeOut,
    this.autoplay = true,
  });

  @override
  State<StaggeredAppear> createState() => _StaggeredAppearState();
}

class _StaggeredAppearState extends State<StaggeredAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anims = Stagger.by(
      _ctrl,
      count: widget.count,
      step: widget.step,
      span: widget.span,
      curve: widget.curve,
    );
    if (widget.autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.count,
        (i) => widget.builder(context, _anims[i], i),
      ),
    );
  }
}

/// 편의 익스텐션: widget.popIn(a), widget.popOut(a)
extension PopTransitionsX on Widget {
  Widget popIn(Animation<double> a) =>
      PopInTransition(animation: a, child: this);

  Widget popOut(Animation<double> a, {Offset to = const Offset(-0.8, 0)}) =>
      PopOutSlideFade(animation: a, to: to, child: this);
}
