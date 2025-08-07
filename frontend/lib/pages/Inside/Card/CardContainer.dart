import 'package:flutter/material.dart';

class PixelCardContainer extends StatelessWidget {
  final double width;
  final Widget child;

  const PixelCardContainer({
    super.key,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PixelCornerPainter(
        color: const Color(0xFF85664A), // 배경색
        pixelSize: 4.0, // 픽셀 한 칸 크기
      ),
      child: Container(
        width: width,
        height: 125,
        padding: const EdgeInsets.only(top: 12, left: 12, bottom: 7),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }
}

class PixelCornerPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  PixelCornerPainter({required this.color, required this.pixelSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // 배경 전체
    canvas.drawRect(
      Rect.fromLTWH(2 * pixelSize, 0, size.width - 2 * pixelSize, size.height),
      paint,
    );

    // 첫 번째 계단 블록
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        2 * pixelSize,
        2 * pixelSize,
        size.height - 2 * pixelSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
