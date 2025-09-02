import 'package:flutter/material.dart';

class CustomCardPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  const CustomCardPainter({required this.color, this.pixelSize = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // ==========================
    // 가로 연결선 (Top & Bottom)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, 0, size.width - 2 * pixelSize, pixelSize),
      paint,
    ); // top

    canvas.drawRect(
      Rect.fromLTWH(
        pixelSize,
        size.height - pixelSize,
        size.width - 2 * pixelSize,
        pixelSize,
      ),
      paint,
    ); // bottom

    // ==========================
    // 세로 연결선 (Left & Right)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(0, pixelSize, pixelSize, size.height - 2 * pixelSize),
      paint,
    ); // left

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - pixelSize,
        pixelSize,
        pixelSize,
        size.height - 2 * pixelSize,
      ),
      paint,
    ); // right

    // ==========================
    // 좌상단 3단 계단 (↙)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(1 * pixelSize, 0, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(2 * pixelSize, 0, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 1 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(1 * pixelSize, 1 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 2 * pixelSize, pixelSize, pixelSize),
      paint,
    );

    // ==========================
    // 우상단 3단 계단 (↘)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3 * pixelSize, 0, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 2 * pixelSize, 0, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
        1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 1 * pixelSize,
        1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 1 * pixelSize,
        2 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );

    // ==========================
    // 좌하단 3단 계단 (↖)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 3 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        1 * pixelSize,
        size.height - 2 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 2 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        1 * pixelSize,
        size.height - 1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        2 * pixelSize,
        size.height - 1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );

    // ==========================
    // 우하단 3단 계단 (↗)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - pixelSize,
        size.height - 3 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
        size.height - 2 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - pixelSize,
        size.height - 2 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
        size.height - 1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 3 * pixelSize,
        size.height - 1 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
