import 'package:flutter/material.dart';
import 'paw_painter.dart';

/// 肉球シールWidget（アニメーション付き）
class PawSticker extends StatefulWidget {
  final Color color;
  final double size;
  final bool animate;
  final VoidCallback? onTap;

  const PawSticker({
    super.key,
    required this.color,
    this.size = 40,
    this.animate = false,
    this.onTap,
  });

  @override
  State<PawSticker> createState() => _PawStickerState();
}

class _PawStickerState extends State<PawSticker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: CustomPaint(
          painter: PawPainter(color: widget.color),
          size: Size(widget.size, widget.size),
        ),
      ),
    );
  }
}
