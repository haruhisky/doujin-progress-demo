import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../features/home/widgets/paw_painter.dart';

/// 肉球スロット（デイリー/イベント共用）
class PawSlot extends StatelessWidget {
  final bool filled;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const PawSlot({
    super.key,
    required this.filled,
    required this.color,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled
              ? color.withOpacity(0.15)
              : AppTheme.borderColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(
            color: filled ? color.withOpacity(0.3) : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: filled
            ? CustomPaint(
                painter: PawPainter(color: color),
                size: Size(size, size),
              )
            : Icon(
                Icons.pets_outlined,
                size: size * 0.45,
                color: AppTheme.textLight.withOpacity(0.4),
              ),
      ),
    );
  }
}
