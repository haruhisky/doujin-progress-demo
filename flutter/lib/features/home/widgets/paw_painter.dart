import 'package:flutter/material.dart';

/// 肉球シールの描画ロジック
class PawPainter extends CustomPainter {
  final Color color;
  final double glossOpacity;

  PawPainter({
    required this.color,
    this.glossOpacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 48; // 基準サイズ48に対するスケール

    // メインパッド（大きな楕円）
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 4 * scale),
        width: 22 * scale,
        height: 18 * scale,
      ),
      paint,
    );

    // 指パッド（4つの小さな楕円）
    final toePositions = [
      Offset(cx - 9 * scale, cy - 8 * scale),
      Offset(cx - 3 * scale, cy - 12 * scale),
      Offset(cx + 3 * scale, cy - 12 * scale),
      Offset(cx + 9 * scale, cy - 8 * scale),
    ];

    for (final pos in toePositions) {
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: 8 * scale,
          height: 10 * scale,
        ),
        paint,
      );
    }

    // グロス（光沢）表現
    final glossPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(glossOpacity),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // メインパッドにグロス
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 2 * scale, cy + 2 * scale),
        width: 14 * scale,
        height: 10 * scale,
      ),
      glossPaint,
    );
  }

  @override
  bool shouldRepaint(PawPainter oldDelegate) =>
      color != oldDelegate.color || glossOpacity != oldDelegate.glossOpacity;
}
