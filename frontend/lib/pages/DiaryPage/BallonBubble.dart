import 'package:flutter/material.dart';

class BalloonBubble extends StatelessWidget {
  final Widget child;
  final double radius;
  final double tailHeight;
  final double tailWidth;

  const BalloonBubble({
    super.key,
    required this.child,
    this.radius = 15.0,
    this.tailHeight = 18.0,
    this.tailWidth = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BalloonPainter(
        radius: radius,
        tailHeight: tailHeight,
        tailWidth: tailWidth,
      ),
      child: Container(
        width: 270,
        margin: EdgeInsets.only(top: tailHeight), // 꼭지점 공간
        padding: const EdgeInsets.all(15.0),
        child: child,
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  final double radius;
  final double tailHeight;
  final double tailWidth;

  static const Color fillColor = Colors.white;
  static const Color borderColor = Color(0xFFE1DDD4);

  BalloonPainter({
    required this.radius,
    required this.tailHeight,
    required this.tailWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Path path = Path();

    // 말풍선 윗면 기준 Y
    final double topY = tailHeight;

    // 삼각형 꼭짓점 위치 (중앙에서 오른쪽으로 치우침)
    final double tipCenterX = size.width - 40;
    final double tipTopY = 0; // 꼭짓점 Y 위치 (위로 뾰족)

    // 말풍선 시작점: 왼쪽 상단 라운드 시작
    path.moveTo(radius, topY);

    // 상단 왼쪽 → 삼각형 왼쪽
    path.lineTo(tipCenterX - 15, topY); // 더 왼쪽으로
    path.lineTo(tipCenterX, tipTopY); // 꼭짓점
    path.lineTo(tipCenterX + 5, topY);

    // 상단 오른쪽까지 직선 + 둥근 모서리
    path.lineTo(size.width - radius, topY);
    path.quadraticBezierTo(size.width, topY, size.width, topY + radius);

    // 오른쪽면
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // 하단면
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // 왼쪽면
    path.lineTo(0, topY + radius);
    path.quadraticBezierTo(0, topY, radius, topY);

    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
