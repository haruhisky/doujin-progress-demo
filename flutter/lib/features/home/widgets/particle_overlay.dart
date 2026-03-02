import 'dart:math';
import 'package:flutter/material.dart';

/// シール貼付時のパーティクルエフェクト
class ParticleOverlay extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const ParticleOverlay({
    super.key,
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    // 4-6個のパーティクルを生成
    final count = 4 + _random.nextInt(3);
    _particles = List.generate(count, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30.0 + _random.nextDouble() * 40;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: 4.0 + _random.nextDouble() * 4,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            center: widget.position,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  _Particle({required this.dx, required this.dy, required this.size});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset center;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.center,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 1.0 - progress;
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      final x = center.dx + p.dx * progress;
      final y = center.dy + p.dy * progress;
      final s = p.size * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => progress != old.progress;
}
