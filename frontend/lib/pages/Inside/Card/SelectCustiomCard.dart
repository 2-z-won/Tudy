import 'package:flutter/material.dart';

class SelectCustomCardPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  const SelectCustomCardPainter({required this.color, this.pixelSize = 3.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final paintY = Paint()..color = Color(0xFFFFD76D);

    // ==========================
    // 가로 연결선 (Top & Bottom)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(2 * pixelSize, 0, size.width - 4 * pixelSize, pixelSize),
      paint,
    ); // top

    canvas.drawRect(
      Rect.fromLTWH(
        2 * pixelSize,
        size.height - pixelSize,
        size.width - 4 * pixelSize,
        pixelSize,
      ),
      paint,
    ); // bottom

    // ==========================
    // 세로 연결선 (Left & Right)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(0, 2 * pixelSize, pixelSize, size.height - 4 * pixelSize),
      paint,
    ); // left

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - pixelSize,
        2 * pixelSize,
        pixelSize,
        size.height - 4 * pixelSize,
      ),
      paint,
    ); // right

    // ==========================
    // 좌상단 3단 계단 (↙)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(1 * pixelSize, 1 * pixelSize, 2 * pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(1 * pixelSize, 2 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    // ==========================
    // 우상단 3단 계단 (↘)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 3 * pixelSize,
        1 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
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
      Rect.fromLTWH(
        pixelSize,
        size.height - 2 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        pixelSize,
        size.height - 3 * pixelSize,
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
        size.width - 3 * pixelSize,
        size.height - 2 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
        size.height - 3 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );

    // =========================================================
    // ==========================
    // 가로 연결선 (Top & Bottom)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        3 * pixelSize,
        pixelSize,
        size.width - 6 * pixelSize,
        pixelSize,
      ),
      paintY,
    ); // top

    canvas.drawRect(
      Rect.fromLTWH(
        3 * pixelSize,
        size.height - 2 * pixelSize,
        size.width - 6 * pixelSize,
        pixelSize,
      ),
      paintY,
    ); // bottom

    // ==========================
    // 세로 연결선 (Left & Right)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        pixelSize,
        3 * pixelSize,
        pixelSize,
        size.height - 6 * pixelSize,
      ),
      paintY,
    ); // left

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 2 * pixelSize,
        3 * pixelSize,
        pixelSize,
        size.height - 6 * pixelSize,
      ),
      paintY,
    ); // right

    // ==========================
    // 좌상단 3단 계단 (↙)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(2 * pixelSize, 2 * pixelSize, 2 * pixelSize, pixelSize),
      paintY,
    );
    canvas.drawRect(
      Rect.fromLTWH(2 * pixelSize, 3 * pixelSize, pixelSize, pixelSize),
      paintY,
    );
    // ==========================
    // 우상단 3단 계단 (↘)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 4 * pixelSize,
        2 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paintY,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 3 * pixelSize,
        3 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paintY,
    );

    // ==========================
    // 좌하단 3단 계단 (↖)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        2 * pixelSize,
        size.height - 3 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paintY,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        2 * pixelSize,
        size.height - 4 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paintY,
    );

    // ==========================
    // 우하단 3단 계단 (↗)
    // ==========================

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 4 * pixelSize,
        size.height - 3 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paintY,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 3 * pixelSize,
        size.height - 4 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paintY,
    );

    // =========================================================
    // ==========================
    // 가로 연결선 (Top & Bottom)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        4 * pixelSize,
        2 * pixelSize,
        size.width - 8 * pixelSize,
        pixelSize,
      ),
      paint,
    ); // top

    canvas.drawRect(
      Rect.fromLTWH(
        4 * pixelSize,
        size.height - 3 * pixelSize,
        size.width - 8 * pixelSize,
        pixelSize,
      ),
      paint,
    ); // bottom

    // ==========================
    // 세로 연결선 (Left & Right)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        2 * pixelSize,
        4 * pixelSize,
        pixelSize,
        size.height - 8 * pixelSize,
      ),
      paint,
    ); // left

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 3 * pixelSize,
        4 * pixelSize,
        pixelSize,
        size.height - 8 * pixelSize,
      ),
      paint,
    ); // right

    // ==========================
    // 좌상단 3단 계단 (↙)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(3 * pixelSize, 3 * pixelSize, 2 * pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(3 * pixelSize, 4 * pixelSize, pixelSize, pixelSize),
      paint,
    );
    // ==========================
    // 우상단 3단 계단 (↘)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 5 * pixelSize,
        3 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 4 * pixelSize,
        4 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );

    // ==========================
    // 좌하단 3단 계단 (↖)
    // ==========================
    canvas.drawRect(
      Rect.fromLTWH(
        3 * pixelSize,
        size.height - 4 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        3 * pixelSize,
        size.height - 5 * pixelSize,
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
        size.width - 5 * pixelSize,
        size.height - 4 * pixelSize,
        2 * pixelSize,
        pixelSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 4 * pixelSize,
        size.height - 5 * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
