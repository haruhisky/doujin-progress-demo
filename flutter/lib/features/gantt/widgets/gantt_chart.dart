import 'package:flutter/material.dart';
import '../../../core/utils.dart';
import '../../../data/models/project.dart';
import 'gantt_painter.dart';

/// ガントチャート全体（CustomPaint + ドラッグ対応）
class GanttChart extends StatefulWidget {
  final Project project;
  final ValueChanged<List<double>> onRatiosChanged;

  const GanttChart({
    super.key,
    required this.project,
    required this.onRatiosChanged,
  });

  @override
  State<GanttChart> createState() => _GanttChartState();
}

class _GanttChartState extends State<GanttChart> {
  static const double headerHeight = 36;
  static const double rowHeight = 56;
  static const double leftLabelWidth = 64;

  int? _draggingHandle;
  late List<double> _ratios;

  @override
  void initState() {
    super.initState();
    _ratios = List.from(widget.project.planRatios);
  }

  @override
  void didUpdateWidget(GanttChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // プロジェクト切替、または工程数変更時にratiosを再同期
    if (oldWidget.project.id != widget.project.id ||
        _ratios.length != widget.project.planRatios.length) {
      _ratios = List.from(widget.project.planRatios);
    }
  }

  /// デモ版準拠の予測データを計算
  List<ForecastItem> _calculateForecast() {
    final project = widget.project;
    final startDate = parseDate(project.startDate);
    final deadline = parseDate(project.deadline);
    final totalDays = daysBetween(startDate, deadline);
    if (totalDays <= 0) return [];

    final processIds = project.processes.map((p) => p.id).toList();
    final processDateCounts = project.processDateCounts;

    return calcForecast(
      totalPages: project.totalPages,
      totalDays: totalDays,
      projectStartDate: project.startDate,
      processIds: processIds,
      processDateCounts: processDateCounts,
      planRatios: project.planRatios,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartHeight =
        headerHeight + widget.project.processes.length * rowHeight + 20;

    final forecast = _calculateForecast();

    return GestureDetector(
      onPanStart: (details) {
        _draggingHandle = _findHandle(details.localPosition);
      },
      onPanUpdate: (details) {
        if (_draggingHandle != null) {
          _updateRatio(details.localPosition);
        }
      },
      onPanEnd: (_) {
        if (_draggingHandle != null) {
          widget.onRatiosChanged(List.from(_ratios));
          _draggingHandle = null;
        }
      },
      child: CustomPaint(
        painter: GanttPainter(
          project: widget.project.copyWith(planRatios: _ratios),
          headerHeight: headerHeight,
          rowHeight: rowHeight,
          leftLabelWidth: leftLabelWidth,
          forecast: forecast,
          draggingHandle: _draggingHandle,
        ),
        size: Size(double.infinity, chartHeight),
        child: SizedBox(
          height: chartHeight,
          child: _buildDragHandles(),
        ),
      ),
    );
  }

  Widget _buildDragHandles() {
    if (_ratios.length <= 1) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final chartWidth = constraints.maxWidth - leftLabelWidth;
      final handles = <Widget>[];

      double cumulative = 0;
      for (int i = 0; i < _ratios.length - 1; i++) {
        cumulative += _ratios[i];
        final x = leftLabelWidth + chartWidth * cumulative;

        handles.add(Positioned(
          left: x - 12,
          top: headerHeight,
          child: Container(
            width: 24,
            height: widget.project.processes.length * rowHeight,
            color: Colors.transparent,
          ),
        ));
      }

      return Stack(children: handles);
    });
  }

  int? _findHandle(Offset position) {
    final chartWidth = (context.size?.width ?? 300) - leftLabelWidth;
    double cumulative = 0;

    for (int i = 0; i < _ratios.length - 1; i++) {
      cumulative += _ratios[i];
      final handleX = leftLabelWidth + chartWidth * cumulative;
      if ((position.dx - handleX).abs() < 16) {
        return i;
      }
    }
    return null;
  }

  void _updateRatio(Offset position) {
    final i = _draggingHandle!;
    final chartWidth = (context.size?.width ?? 300) - leftLabelWidth;
    final relX = (position.dx - leftLabelWidth) / chartWidth;

    double before = 0;
    for (int j = 0; j < i; j++) {
      before += _ratios[j];
    }

    final newRatio = (relX - before)
        .clamp(0.05, 1.0 - before - 0.05 * (_ratios.length - i - 1));
    final diff = newRatio - _ratios[i];

    setState(() {
      _ratios[i] = newRatio;
      _ratios[i + 1] = (_ratios[i + 1] - diff).clamp(0.05, 1.0);

      final sum = _ratios.reduce((a, b) => a + b);
      for (int j = 0; j < _ratios.length; j++) {
        _ratios[j] = _ratios[j] / sum;
      }
    });
  }
}
