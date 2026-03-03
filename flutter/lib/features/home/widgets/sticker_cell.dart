import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'paw_painter.dart';
import 'particle_overlay.dart';

/// シールの位置データ
class StickerPosition {
  final double xPct; // 0-100
  final double yPct; // 0-100
  final int index;
  final double rotation; // radians

  StickerPosition({
    required this.xPct,
    required this.yPct,
    required this.index,
    required this.rotation,
  });
}

/// 1工程分のシールセル（タップした位置にシールが貼られる）
class StickerCell extends StatefulWidget {
  final String processId;
  final String label;
  final String icon;
  final Color color;
  final int todayCount;
  final int totalCompleted;
  final int totalPages;
  final int pastCount;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback? onRemoveLatest;
  final VoidCallback? onAddPast;
  final VoidCallback? onProcessComplete;
  final bool hideCompletionLabel;

  const StickerCell({
    super.key,
    required this.processId,
    required this.label,
    required this.icon,
    required this.color,
    required this.todayCount,
    required this.totalCompleted,
    required this.totalPages,
    this.pastCount = 0,
    required this.onTap,
    required this.onRemove,
    this.onRemoveLatest,
    this.onAddPast,
    this.onProcessComplete,
    this.hideCompletionLabel = false,
  });

  @override
  State<StickerCell> createState() => _StickerCellState();
}

/// パーティクル発火データ
class _ParticleData {
  final Key key;
  final Offset position;
  _ParticleData({required this.key, required this.position});
}

class _StickerCellState extends State<StickerCell> {
  final List<StickerPosition> _stickerPositions = [];
  final List<_ParticleData> _particles = [];
  final _random = Random();
  int? _newestIndex;
  int _particleKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _syncPositions();
  }

  @override
  void didUpdateWidget(StickerCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPositions();
  }

  /// todayCountに合わせてシール位置を同期
  void _syncPositions() {
    while (_stickerPositions.length < widget.todayCount) {
      _stickerPositions.add(StickerPosition(
        xPct: 10 + _random.nextDouble() * 75,
        yPct: 10 + _random.nextDouble() * 70,
        index: _stickerPositions.length,
        rotation: (_random.nextDouble() - 0.5) * 0.52, // -15°〜+15°
      ));
    }
    while (_stickerPositions.length > widget.todayCount) {
      _stickerPositions.removeLast();
    }
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    final tapPos = details.localPosition;

    // 既存シールとの当たり判定（後ろから検索 = 上に表示されているものを優先）
    for (int i = _stickerPositions.length - 1; i >= 0; i--) {
      final pos = _stickerPositions[i];
      final cx = (pos.xPct / 100) * constraints.maxWidth;
      final cy = (pos.yPct / 100) * constraints.maxHeight;
      if ((tapPos - Offset(cx, cy)).distance < 24) {
        // シール削除
        setState(() {
          _stickerPositions.removeAt(i);
          _newestIndex = null;
        });
        HapticFeedback.lightImpact();
        widget.onRemove();
        return;
      }
    }

    // ページ上限チェック
    if (widget.totalCompleted >= widget.totalPages) {
      HapticFeedback.heavyImpact();
      return;
    }

    // 新しいシールを追加
    final x = (tapPos.dx / constraints.maxWidth) * 100;
    final y = (tapPos.dy / constraints.maxHeight) * 100;
    final offsetX =
        (x + (_random.nextDouble() - 0.5) * 10).clamp(5.0, 90.0);
    final offsetY =
        (y + (_random.nextDouble() - 0.5) * 10).clamp(5.0, 85.0);

    setState(() {
      _stickerPositions.add(StickerPosition(
        xPct: offsetX,
        yPct: offsetY,
        index: _stickerPositions.length,
        rotation: (_random.nextDouble() - 0.5) * 0.52, // -15°〜+15°
      ));
      _newestIndex = _stickerPositions.length - 1;
      // パーティクル発火
      _particles.add(_ParticleData(
        key: ValueKey('particle_${_particleKeyCounter++}'),
        position: tapPos,
      ));
    });

    HapticFeedback.lightImpact();
    widget.onTap();
    // 工程完了チェック（このタップで完了ページに達した場合）
    if (widget.totalCompleted + 1 >= widget.totalPages) {
      widget.onProcessComplete?.call();
    }
  }

  /// 脱色カラー（彩度を落とした灰色寄りのカラー）
  Color get _grayColor {
    return HSLColor.fromColor(widget.color)
        .withSaturation(0.15)
        .withLightness(0.65)
        .toColor();
  }

  /// 過去シールエリアを構築（常設）
  Widget _buildPastArea() {
    final pastCount = widget.pastCount;
    final grayColor = _grayColor;
    final largeLabel = pastCount >= 10 ? (pastCount ~/ 10) * 10 : 0;
    final smallCount = pastCount > 0 ? pastCount % 10 : 0;
    final isComplete = widget.totalCompleted >= widget.totalPages;
    final minusDisabled = pastCount <= 0;
    final plusDisabled = isComplete;

    return GestureDetector(
      onTapDown: (_) {}, // タップ吸収（誤爆防止）
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景テキスト
            if (pastCount == 0)
              Text(
                '達成済みのシール',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Row(
              children: [
                // [−] ボタン
                _PastActionButton(
                  icon: Icons.remove,
                  disabled: minusDisabled,
                  color: grayColor,
                  onPressed: widget.onRemoveLatest,
                ),
                // シール列（横スクロール可能）
                Expanded(
                  child: pastCount > 0
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (largeLabel > 0)
                                _LargePastSticker(
                                  color: grayColor,
                                  label: '$largeLabel',
                                ),
                              for (int j = 0; j < smallCount; j++)
                                _SmallPastSticker(color: grayColor),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // [＋] ボタン
                _PastActionButton(
                  icon: Icons.add,
                  disabled: plusDisabled,
                  color: grayColor,
                  onPressed: widget.onAddPast,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.totalCompleted >= widget.totalPages;
    return Container(
      decoration: BoxDecoration(
        color: widget.color.withOpacity(isComplete ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withOpacity(isComplete ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 過去シールエリア
          _buildPastArea(),
          // 区切り線
          Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(
              children: [
                Text(widget.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.totalCompleted}/${widget.totalPages}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
          // シール貼りエリア
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _onTapDown(details, constraints),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 空の場合のヒント / 完了表示
                      if (_stickerPositions.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isComplete
                                    ? Icons.check_circle_outline
                                    : Icons.pets_outlined,
                                size: 28,
                                color: widget.color.withOpacity(
                                    isComplete ? 0.5 : 0.4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isComplete ? '完了!' : 'タップでシールを貼る',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.color.withOpacity(
                                      isComplete ? 0.6 : 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // パーティクルエフェクト
                      ..._particles.map((p) => ParticleOverlay(
                            key: p.key,
                            position: p.position,
                            color: widget.color,
                            onComplete: () {
                              setState(() => _particles.remove(p));
                            },
                          )),
                      // シール
                      ..._stickerPositions.asMap().entries.map((entry) {
                        final i = entry.key;
                        final pos = entry.value;
                        final left =
                            (pos.xPct / 100) * constraints.maxWidth - 20;
                        final top =
                            (pos.yPct / 100) * constraints.maxHeight - 20;
                        final isNewest = i == _newestIndex;

                        return Positioned(
                          left: left,
                          top: top,
                          child: _AnimatedSticker(
                            color: widget.color,
                            animate: isNewest,
                            rotation: pos.rotation,
                          ),
                        );
                      }),
                      // 完了ラベル（半透明、タップ貫通）— 犬の手アニメ中は非表示
                      if (isComplete && !widget.hideCompletionLabel)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.08,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: widget.color.withOpacity(0.5),
                                        width: 2.5),
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  child: Text(
                                    '完了!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: widget.color.withOpacity(0.6),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 過去エリアの [+] / [-] ボタン
class _PastActionButton extends StatelessWidget {
  final IconData icon;
  final bool disabled;
  final Color color;
  final VoidCallback? onPressed;

  const _PastActionButton({
    required this.icon,
    required this.disabled,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(
          icon,
          color: disabled ? Colors.grey.shade400 : color,
        ),
        onPressed: disabled ? null : onPressed,
      ),
    );
  }
}

/// 大シール（10個集約、数字ラベル付き）
class _LargePastSticker extends StatelessWidget {
  final Color color;
  final String label;

  const _LargePastSticker({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(32, 32),
              painter: PawPainter(color: color, glossOpacity: 0.1),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 小シール（1個分）
class _SmallPastSticker extends StatelessWidget {
  final Color color;

  const _SmallPastSticker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: CustomPaint(
        size: const Size(18, 18),
        painter: PawPainter(color: color, glossOpacity: 0.1),
      ),
    );
  }
}

/// アニメーション付きシール（表示のみ、タップ判定は親が管理）
class _AnimatedSticker extends StatefulWidget {
  final Color color;
  final bool animate;
  final double rotation;

  const _AnimatedSticker({
    required this.color,
    required this.animate,
    required this.rotation,
  });

  @override
  State<_AnimatedSticker> createState() => _AnimatedStickerState();
}

class _AnimatedStickerState extends State<_AnimatedSticker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.85), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: Transform.rotate(
            angle: widget.rotation,
            child: child,
          ),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: PawPainter(color: widget.color),
          ),
        ),
      ),
    );
  }
}
