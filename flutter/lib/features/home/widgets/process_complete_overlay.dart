import 'dart:math';
import 'package:flutter/material.dart';

/// 工程完了時の犬の手スタンプ演出
/// 犬の手がセルの真上からスライドイン→ポンと押す→キラキラ→スライドアウト
/// 「完了!」ラベルはStickerCell側で永続表示するため、ここでは犬の手+キラキラのみ
class ProcessCompleteOverlay extends StatefulWidget {
  final Color color;
  final Rect targetRect; // 完了セルの位置（親Stack内座標）
  final VoidCallback onComplete;
  final VoidCallback? onStamp; // ポン押し後（手がまだ覆っている間）に発火

  const ProcessCompleteOverlay({
    super.key,
    required this.color,
    required this.targetRect,
    required this.onComplete,
    this.onStamp,
  });

  @override
  State<ProcessCompleteOverlay> createState() =>
      _ProcessCompleteOverlayState();
}

class _ProcessCompleteOverlayState extends State<ProcessCompleteOverlay>
    with TickerProviderStateMixin {
  // フェーズ1: 犬の手スライドイン
  late AnimationController _slideInCtrl;
  late Animation<double> _slideInAnim;

  // フェーズ2: ポンと押す
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  // フェーズ3: キラキラ
  late AnimationController _sparkleCtrl;

  // フェーズ4: 犬の手スライドアウト
  late AnimationController _slideOutCtrl;
  late Animation<double> _slideOutAnim;

  // キラキラパーティクル
  late List<_Sparkle> _sparkles;
  final _random = Random();

  bool _showSparkles = false;

  @override
  void initState() {
    super.initState();

    // キラキラ生成
    _sparkles = List.generate(10, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final dist = 30.0 + _random.nextDouble() * 50;
      return _Sparkle(
        dx: cos(angle) * dist,
        dy: sin(angle) * dist,
        size: 3.0 + _random.nextDouble() * 4,
        rotSpeed: (_random.nextDouble() - 0.5) * 4,
      );
    });

    // フェーズ1: スライドイン (0.4s)
    _slideInCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideInAnim = CurvedAnimation(
      parent: _slideInCtrl,
      curve: Curves.easeOutCubic,
    );

    // フェーズ2: ポン押し (0.25s)
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _pressAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.93), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.0), weight: 30),
    ]).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));

    // フェーズ3: キラキラ (0.6s)
    _sparkleCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // フェーズ4: スライドアウト (0.4s)
    _slideOutCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideOutAnim = CurvedAnimation(
      parent: _slideOutCtrl,
      curve: Curves.easeInCubic,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // フェーズ1: スライドイン
    await _slideInCtrl.forward();
    if (!mounted) return;

    // フェーズ2: ポン
    await _pressCtrl.forward();
    if (!mounted) return;

    // ポン直後（手がまだ覆っている間）にラベル表示を通知
    widget.onStamp?.call();

    // フェーズ3: キラキラ
    setState(() => _showSparkles = true);
    _sparkleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // フェーズ4: スライドアウト
    await _slideOutCtrl.forward();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _slideInCtrl.dispose();
    _pressCtrl.dispose();
    _sparkleCtrl.dispose();
    _slideOutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 犬の手サイズ: 画面幅の100%（前回の2倍）
    final handWidth = screenWidth * 1.0;
    final handHeight = handWidth * 1.25; // アスペクト比維持

    // 肉球の位置は画像の約55%地点（上から）— 1セル分下げた補正
    const pawFraction = 0.55;

    // セルの中心座標
    final cellCenterX =
        widget.targetRect.left + widget.targetRect.width / 2;
    final cellCenterY =
        widget.targetRect.top + widget.targetRect.height / 2;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _slideInCtrl,
          _pressCtrl,
          _sparkleCtrl,
          _slideOutCtrl,
        ]),
        builder: (context, _) {
          // 犬の手のY位置計算
          // 肉球（画像の85%地点）がセル中心に来るように配置
          // pawY = handTopY + handHeight * pawFraction = cellCenterY
          // → handTopY = cellCenterY - handHeight * pawFraction
          final handTopTarget = cellCenterY - handHeight * pawFraction;
          final handTopStart = handTopTarget - handHeight; // 画面外上（手一本分上）

          double handTopY;
          if (_slideOutCtrl.isAnimating || _slideOutCtrl.isCompleted) {
            // スライドアウト: target → 画面外上
            handTopY = handTopTarget +
                (handTopStart - handTopTarget) * _slideOutAnim.value;
          } else {
            // スライドイン: 画面外上 → target
            handTopY = handTopStart +
                (handTopTarget - handTopStart) * _slideInAnim.value;
          }

          // ポン押しのスケール（肉球位置を中心にスケール）
          final pressScale =
              _pressCtrl.isAnimating ? _pressAnim.value : 1.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 犬の手（セルの真上から降りてくる）
              Positioned(
                left: cellCenterX - handWidth / 2,
                top: handTopY,
                child: Transform.scale(
                  scale: pressScale,
                  alignment: Alignment(0, pawFraction * 2 - 1), // 肉球位置を中心にスケール
                  child: Image.asset(
                    'assets/images/dog_hand.png',
                    width: handWidth,
                    height: handHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // キラキラエフェクト（セル中心付近）
              if (_showSparkles)
                Positioned(
                  left: cellCenterX - 75,
                  top: cellCenterY - 75,
                  child: CustomPaint(
                    painter: _SparklePainter(
                      sparkles: _sparkles,
                      progress: _sparkleCtrl.value,
                      color: widget.color,
                    ),
                    size: const Size(150, 150),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Sparkle {
  final double dx;
  final double dy;
  final double size;
  final double rotSpeed;
  _Sparkle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotSpeed,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double progress;
  final Color color;

  _SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final opacity =
        (1.0 - (progress - 0.3).clamp(0.0, 1.0) / 0.7).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    for (final s in sparkles) {
      final t = progress.clamp(0.0, 0.6) / 0.6;
      final x = center.dx + s.dx * t;
      final y = center.dy + s.dy * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(s.rotSpeed * progress * pi);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      final starSize = s.size * (1.0 - progress * 0.3);
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = (i * pi / 2) - pi / 4;
        final outerX = cos(angle) * starSize;
        final outerY = sin(angle) * starSize;
        final innerAngle = angle + pi / 4;
        final innerX = cos(innerAngle) * starSize * 0.4;
        final innerY = sin(innerAngle) * starSize * 0.4;
        if (i == 0) {
          path.moveTo(outerX, outerY);
        } else {
          path.lineTo(outerX, outerY);
        }
        path.lineTo(innerX, innerY);
      }
      path.close();
      canvas.drawPath(path, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => progress != old.progress;
}
