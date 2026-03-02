import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../data/models/project.dart';

/// ガントチャートの描画ロジック
class GanttPainter extends CustomPainter {
  final Project project;
  final double headerHeight;
  final double rowHeight;
  final double leftLabelWidth;
  final List<ForecastItem> forecast;
  final int? draggingHandle;

  GanttPainter({
    required this.project,
    this.headerHeight = 36,
    this.rowHeight = 56,
    this.leftLabelWidth = 64,
    this.forecast = const [],
    this.draggingHandle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - leftLabelWidth;
    final startDate = parseDate(project.startDate);
    final deadline = parseDate(project.deadline);
    final totalDays = daysBetween(startDate, deadline);
    if (totalDays <= 0) return;

    final today = DateTime.now();
    final processes = project.processes;
    final ratios = project.planRatios;
    final completedMap = project.completedByProcess;

    // ── 背景グリッド ──
    _drawGrid(canvas, size, chartWidth, totalDays, startDate);

    // ── 今日線 ──
    _drawTodayLine(canvas, size, chartWidth, totalDays, startDate, today);

    // ── 各工程のバー ──
    double cumulativeRatio = 0;
    for (int i = 0; i < processes.length; i++) {
      final proc = processes[i];
      final ratio = i < ratios.length ? ratios[i] : 1.0 / processes.length;
      final color = colorFromHex(proc.color);

      final y = headerHeight + i * rowHeight;

      // ラベル
      _drawLabel(canvas, proc.icon, proc.label, y, rowHeight);

      // 計画バー
      final planStartX = leftLabelWidth + chartWidth * cumulativeRatio;
      final planWidth = chartWidth * ratio;
      _drawPlanBar(canvas, planStartX, y + 10, planWidth, 16, color);

      // 実績バー（計画バー内に表示、デモ版準拠）
      final completed = completedMap[proc.id] ?? 0;
      if (completed > 0) {
        final doneFrac = (completed / project.totalPages).clamp(0.0, 1.0);
        final actualWidth = planWidth * doneFrac;
        _drawActualBar(canvas, planStartX, y + 30, actualWidth, 12, color);
      }

      // 予測バー（デモ版準拠: 連鎖的に表示）
      if (i < forecast.length && forecast[i].widthFrac > 0) {
        final fc = forecast[i];
        final fcStartX = leftLabelWidth + chartWidth * fc.startFrac;
        final fcWidth = (chartWidth * fc.widthFrac).clamp(0.0, chartWidth);

        // 計画バーの終了位置と比較して遅延/余裕を判定
        final planEndFrac = cumulativeRatio + ratio;
        final forecastEndFrac = fc.startFrac + fc.widthFrac;
        final isLate = forecastEndFrac > planEndFrac + 0.01;

        _drawForecastBar(
            canvas, fcStartX, y + 30, fcWidth, 12, color, isLate);
      }

      cumulativeRatio += ratio;
    }

    // ── 工程境界のドラッグハンドル ──
    _drawDragHandles(canvas, size, chartWidth, totalDays, startDate, ratios);

    // ── 締切線 ──
    _drawDeadlineLine(canvas, size, leftLabelWidth + chartWidth);
  }

  void _drawGrid(Canvas canvas, Size size, double chartWidth, int totalDays,
      DateTime startDate) {
    final paint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.5)
      ..strokeWidth = 0.5;

    final endDate = startDate.add(Duration(days: totalDays));
    final spansYears = startDate.year != endDate.year;

    for (int d = 0; d <= totalDays; d++) {
      final date = startDate.add(Duration(days: d));
      if (date.day == 1 || d == 0) {
        final x = leftLabelWidth + chartWidth * (d / totalDays);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

        // 年をまたぐ場合は1月か最初のラベルに年を表示
        final showYear = spansYears && (date.month == 1 || d == 0);
        final labelText =
            showYear ? '${date.year}年${date.month}月' : '${date.month}月';

        final tp = TextPainter(
          text: TextSpan(
            text: labelText,
            style: TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 4));
      }
    }
  }

  void _drawTodayLine(Canvas canvas, Size size, double chartWidth,
      int totalDays, DateTime startDate, DateTime today) {
    final elapsed = daysBetween(startDate, today);
    if (elapsed < 0 || elapsed > totalDays) return;
    final x = leftLabelWidth + chartWidth * (elapsed / totalDays);
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.7)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x, headerHeight), Offset(x, size.height), paint);

    final tp = TextPainter(
      text: TextSpan(
        text: '今日',
        style: TextStyle(
            fontSize: 9,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, headerHeight - 14));
  }

  void _drawDeadlineLine(Canvas canvas, Size size, double x) {
    final paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x, headerHeight), Offset(x, size.height), paint);
  }

  void _drawLabel(
      Canvas canvas, String icon, String label, double y, double height) {
    final iconTp = TextPainter(
      text: TextSpan(text: icon, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    iconTp.paint(canvas, Offset(4, y + height / 2 - iconTp.height / 2));

    final labelTp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
            fontSize: 11,
            color: AppTheme.textColor,
            fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(22, y + height / 2 - labelTp.height / 2));
  }

  void _drawPlanBar(Canvas canvas, double x, double y, double width,
      double height, Color color) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height), const Radius.circular(4));
    canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.25));
    canvas.drawRRect(
        rect,
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _drawActualBar(Canvas canvas, double x, double y, double width,
      double height, Color color) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height), const Radius.circular(3));
    canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.7));
  }

  void _drawForecastBar(Canvas canvas, double x, double y, double width,
      double height, Color color, bool isLate) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height), const Radius.circular(3));
    // 遅延: 赤系、余裕: 緑系
    final barColor = isLate
        ? Colors.redAccent.withOpacity(0.2)
        : const Color(0xFF8EBB9E).withOpacity(0.2);
    final borderColor = isLate
        ? Colors.redAccent.withOpacity(0.5)
        : const Color(0xFF8EBB9E).withOpacity(0.5);
    canvas.drawRRect(rect, Paint()..color = barColor);
    canvas.drawRRect(
        rect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _drawDragHandles(Canvas canvas, Size size, double chartWidth,
      int totalDays, DateTime startDate, List<double> ratios) {
    if (ratios.length <= 1) return;

    double cumulative = 0;
    final chartBottom = headerHeight + project.processes.length * rowHeight;

    for (int i = 0; i < ratios.length - 1; i++) {
      cumulative += ratios[i];
      final x = leftLabelWidth + chartWidth * cumulative;
      final isDragging = draggingHandle == i;

      // 縦の点線
      final linePaint = Paint()
        ..color = AppTheme.textLight.withOpacity(isDragging ? 0.5 : 0.3)
        ..strokeWidth = isDragging ? 1.5 : 1;
      canvas.drawLine(
          Offset(x, headerHeight), Offset(x, chartBottom), linePaint);

      // 白丸ハンドル
      final handleY = headerHeight + (chartBottom - headerHeight) / 2;
      final radius = isDragging ? 8.0 : 6.0;
      // 白い円
      canvas.drawCircle(
          Offset(x, handleY), radius, Paint()..color = Colors.white);
      // 縁取り
      canvas.drawCircle(
        Offset(x, handleY),
        radius,
        Paint()
          ..color = isDragging
              ? AppTheme.primary
              : AppTheme.textLight.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isDragging ? 2 : 1.5,
      );
      // 内側の点（ドラッグ中）
      if (isDragging) {
        canvas.drawCircle(
            Offset(x, handleY), 3, Paint()..color = AppTheme.primary);
      }

      // ドラッグ中の日付フキダシ
      if (isDragging) {
        final dayOffset = (cumulative * totalDays).round();
        final date = startDate.add(Duration(days: dayOffset));
        final dateText = '${date.month}/${date.day}';

        final tp = TextPainter(
          text: TextSpan(
            text: dateText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final tooltipWidth = tp.width + 12;
        final tooltipHeight = tp.height + 8;
        final tooltipX = x - tooltipWidth / 2;
        final tooltipY = headerHeight - tooltipHeight - 6;

        // 背景
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
            const Radius.circular(4),
          ),
          Paint()..color = AppTheme.primary.withOpacity(0.9),
        );
        // テキスト
        tp.paint(canvas, Offset(tooltipX + 6, tooltipY + 4));
      }
    }
  }

  @override
  bool shouldRepaint(GanttPainter oldDelegate) => true;
}
