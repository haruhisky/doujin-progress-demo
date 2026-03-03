import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/sticker_provider.dart';
import 'sticker_cell.dart';
import 'process_complete_overlay.dart';

/// 工程別タップグリッド（2x2レイアウト）
class TapGrid extends ConsumerStatefulWidget {
  const TapGrid({super.key});

  @override
  ConsumerState<TapGrid> createState() => _TapGridState();
}

class _TapGridState extends ConsumerState<TapGrid> {
  bool _showProjectComplete = false;
  bool _showProcessComplete = false;
  Color _processCompleteColor = Colors.transparent;
  Rect? _processCompleteRect; // 完了セルの位置（TapGrid内座標）
  int? _hideCompletionLabelIndex; // 犬の手アニメ中にラベルを隠すセルのindex
  final _gridKey = GlobalKey();
  final Map<int, GlobalKey> _cellKeys = {};

  GlobalKey _getCellKey(int index) {
    return _cellKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _onProcessComplete(int index, Color color) {
    HapticFeedback.mediumImpact();

    // セルの位置を取得（TapGridの座標系に変換）
    final cellKey = _cellKeys[index];
    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    final cellBox = cellKey?.currentContext?.findRenderObject() as RenderBox?;

    if (gridBox != null && cellBox != null) {
      final cellPos = cellBox.localToGlobal(Offset.zero,
          ancestor: gridBox);
      final cellSize = cellBox.size;
      setState(() {
        _showProcessComplete = true;
        _processCompleteColor = color;
        _processCompleteRect =
            Rect.fromLTWH(cellPos.dx, cellPos.dy, cellSize.width, cellSize.height);
        _hideCompletionLabelIndex = index;
      });
    }
  }

  /// 5個目以降の工程を2列ペアで生成
  List<Widget> _buildExtraRows(int total, Widget Function(int) buildCell) {
    final rows = <Widget>[];
    for (int i = 4; i < total; i += 2) {
      if (i + 1 < total) {
        // 2個ペア
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: buildCell(i)),
                const SizedBox(width: 8),
                Expanded(child: buildCell(i + 1)),
              ],
            ),
          ),
        ));
      } else {
        // 奇数で余った1個は半分幅
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: buildCell(i)),
                const SizedBox(width: 8),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ));
      }
    }
    return rows;
  }

  void _checkProjectComplete() {
    final project = ref.read(activeProjectProvider);
    if (project == null) return;
    final completedTotal = ref.read(completedByProcessProvider);
    final allComplete = project.processes.every(
        (proc) => (completedTotal[proc.id] ?? 0) >= project.totalPages);
    if (allComplete) {
      setState(() => _showProjectComplete = true);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showProjectComplete = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(activeProjectProvider);
    if (project == null) {
      return const Center(child: Text('プロジェクトがありません'));
    }

    final today = ref.watch(todayProvider);
    final todayLogs = ref.watch(todayStickerLogsProvider);
    final completedTotal = ref.watch(completedByProcessProvider);
    final processes = project.processes;

    if (processes.isEmpty) return const SizedBox.shrink();

    // 各工程の今日のシール数を取得
    List<int> todayCounts = processes.map((proc) {
      return todayLogs
          .where((l) => l.process == proc.id)
          .fold<int>(0, (sum, l) => sum + l.count);
    }).toList();

    Widget buildCell(int index) {
      final proc = processes[index];
      final todayCount = todayCounts[index];
      final totalCompleted = completedTotal[proc.id] ?? 0;

      return KeyedSubtree(
        key: _getCellKey(index),
        child: StickerCell(
          processId: proc.id,
          label: proc.label,
          icon: proc.icon,
          color: colorFromHex(proc.color),
          todayCount: todayCount,
          totalCompleted: totalCompleted,
          totalPages: project.totalPages,
          hideCompletionLabel: _hideCompletionLabelIndex == index,
          onTap: () async {
            await ref
                .read(projectsProvider.notifier)
                .addSticker(project.id, proc.id, today);
            if (!mounted) return;
            _checkProjectComplete();
          },
          onRemove: () {
            ref
                .read(projectsProvider.notifier)
                .removeSticker(project.id, proc.id, today);
          },
          onProcessComplete: () =>
              _onProcessComplete(index, colorFromHex(proc.color)),
        ),
      );
    }

    Widget grid;

    // 2x2グリッドレイアウト
    if (processes.length == 1) {
      grid = SizedBox(
        height: 300,
        child: buildCell(0),
      );
    } else if (processes.length == 2) {
      grid = SizedBox(
        height: 300,
        child: Row(
          children: [
            Expanded(child: buildCell(0)),
            const SizedBox(width: 8),
            Expanded(child: buildCell(1)),
          ],
        ),
      );
    } else if (processes.length == 3) {
      grid = Column(
        children: [
          SizedBox(
            height: 200,
            child: buildCell(0),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: buildCell(1)),
                const SizedBox(width: 8),
                Expanded(child: buildCell(2)),
              ],
            ),
          ),
        ],
      );
    } else {
      // 4工程以上: 上段2つ + 下段2つ（残りは下に追加）
      grid = Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(child: buildCell(0)),
                const SizedBox(width: 8),
                Expanded(child: buildCell(1)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: buildCell(2)),
                const SizedBox(width: 8),
                Expanded(child: buildCell(3)),
              ],
            ),
          ),
          // 5個目以降（2列ペアで追加）
          ..._buildExtraRows(processes.length, buildCell),
        ],
      );
    }

    return Stack(
      key: _gridKey,
      clipBehavior: Clip.none,
      children: [
        grid,
        // 工程完了の犬の手スタンプ演出
        if (_showProcessComplete && _processCompleteRect != null)
          Positioned.fill(
            child: ProcessCompleteOverlay(
              color: _processCompleteColor,
              targetRect: _processCompleteRect!,
              onStamp: () =>
                  setState(() => _hideCompletionLabelIndex = null),
              onComplete: () =>
                  setState(() => _showProcessComplete = false),
            ),
          ),
        // プロジェクト完了の全画面演出
        if (_showProjectComplete)
          Positioned.fill(
            child: _ProjectCompleteOverlay(
              onDismiss: () => setState(() => _showProjectComplete = false),
            ),
          ),
      ],
    );
  }
}

/// プロジェクト完了のお祝い演出（犬の手+紙吹雪+カード）
class _ProjectCompleteOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const _ProjectCompleteOverlay({required this.onDismiss});

  @override
  State<_ProjectCompleteOverlay> createState() =>
      _ProjectCompleteOverlayState();
}

class _ProjectCompleteOverlayState extends State<_ProjectCompleteOverlay>
    with TickerProviderStateMixin {
  // 犬の手スライドイン
  late AnimationController _handCtrl;
  late Animation<double> _handSlideAnim;
  late Animation<double> _handPressAnim;

  // カード + 紙吹雪
  late AnimationController _mainCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // フェードアウト
  late AnimationController _outCtrl;
  late Animation<double> _fadeOutAnim;

  final _random = Random();
  late List<_Confetti> _confetti;
  bool _showCard = false;

  @override
  void initState() {
    super.initState();

    // 犬の手 (0.8s)
    _handCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _handSlideAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -350.0, end: -20.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: -20.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _handCtrl, curve: Curves.easeOutCubic));
    _handPressAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _handCtrl, curve: Curves.easeInOut));

    // メインカード (3s)
    _mainCtrl = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(_mainCtrl);
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 75),
    ]).animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOut));

    // フェードアウト (0.5s)
    _outCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outCtrl, curve: Curves.easeIn),
    );

    // 紙吹雪パーティクル（50個）
    _confetti = List.generate(50, (_) {
      return _Confetti(
        x: _random.nextDouble(),
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 4 + _random.nextDouble() * 6,
        color: [
          AppTheme.primary,
          AppTheme.secondary,
          const Color(0xFF8EBB9E),
          const Color(0xFFD4BC8A),
          const Color(0xFFB8A0C9),
        ][_random.nextInt(5)],
        wobble: _random.nextDouble() * 2 * pi,
      );
    });

    _runSequence();
  }

  Future<void> _runSequence() async {
    // フェーズ1: 犬の手がスライドイン+ポン
    await _handCtrl.forward();
    if (!mounted) return;

    // フェーズ2: カード+紙吹雪
    setState(() => _showCard = true);
    _mainCtrl.forward();

    // 3秒後にフェードアウト
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    await _outCtrl.forward();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _handCtrl.dispose();
    _mainCtrl.dispose();
    _outCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: AnimatedBuilder(
        animation: Listenable.merge([_handCtrl, _mainCtrl, _outCtrl]),
        builder: (context, child) {
          final overallOpacity = _outCtrl.isAnimating || _outCtrl.isCompleted
              ? _fadeOutAnim.value
              : 1.0;

          return Opacity(
            opacity: overallOpacity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 紙吹雪
                if (_showCard)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConfettiPainter(
                        confetti: _confetti,
                        progress: _mainCtrl.value,
                      ),
                    ),
                  ),

                // 犬の手
                if (!_showCard || _mainCtrl.value < 0.3)
                  Transform.translate(
                    offset: Offset(0, _handSlideAnim.value),
                    child: Transform.scale(
                      scale: _handPressAnim.value,
                      child: Image.asset(
                        'assets/images/dog_hand.png',
                        width: 200,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // カード
                if (_showCard)
                  Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 犬アイコン
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/new_icon.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'プロジェクト完了！',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'おつかれさまでした！',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Confetti {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double wobble;
  _Confetti({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobble,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;
      final paint = Paint()
        ..color = c.color.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;
      final x = c.x * size.width + sin(progress * 6 + c.wobble) * 20;
      final y = -10 + progress * size.height * c.speed * 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x, y), width: c.size, height: c.size * 1.5),
          Radius.circular(c.size * 0.3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => progress != old.progress;
}
