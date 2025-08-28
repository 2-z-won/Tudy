// import 'package:flutter/material.dart';

// class SequentialBounceLoader extends StatefulWidget {
//   const SequentialBounceLoader({
//     super.key,
//     this.color = Colors.white,
//     this.size = 16.0,
//     this.gap = 12.0,
//     this.duration = const Duration(milliseconds: 500),
//     this.maxTranslateY = 14.0,
//   });

//   final Color color;
//   final double size;
//   final double gap;
//   final Duration duration;
//   final double maxTranslateY;

//   @override
//   State<SequentialBounceLoader> createState() => _SequentialBounceLoaderState();
// }

// class _SequentialBounceLoaderState extends State<SequentialBounceLoader>
//     with TickerProviderStateMixin {
//   late final List<AnimationController> _controllers;
//   late final List<Animation<double>> _animations;
//   final int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     _controllers = List.generate(
//       3,
//       (_) => AnimationController(vsync: this, duration: widget.duration),
//     );

//     _animations = _controllers.map((controller) {
//       return Tween<double>(
//         begin: 0,
//         end: -widget.maxTranslateY,
//       ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
//     }).toList();

//     // 첫 번째 점 시작
//     _playNext(0);
//   }

//   void _playNext(int index) {
//     final controller = _controllers[index];
//     controller.forward().then((_) {
//       controller.reverse().then((_) {
//         // 다음 점으로 넘어가기
//         final nextIndex = (index + 1) % 3;
//         _playNext(nextIndex);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Widget _buildDot(Animation<double> anim) {
//     return AnimatedBuilder(
//       animation: anim,
//       builder: (_, child) =>
//           Transform.translate(offset: Offset(0, anim.value), child: child),
//       child: Container(
//         width: widget.size,
//         height: widget.size,
//         decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildDot(_animations[0]),
//         SizedBox(width: widget.gap),
//         _buildDot(_animations[1]),
//         SizedBox(width: widget.gap),
//         _buildDot(_animations[2]),
//       ],
//     );
//   }
// }
