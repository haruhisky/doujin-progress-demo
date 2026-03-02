import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../data/models/project.dart';

/// ペース分析パネル（デモ版準拠）
class PaceAnalysis extends StatelessWidget {
  final Project project;

  const PaceAnalysis({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final startDate = parseDate(project.startDate);
    final deadline = parseDate(project.deadline);
    final totalDays = daysBetween(startDate, deadline);
    final elapsed = daysBetween(startDate, DateTime.now());
    final daysLeft = totalDays - elapsed;

    final completedMap = project.completedByProcess;
    final processDateCounts = project.processDateCounts;
    final processes = project.processes;

    // 予測データ計算
    final forecast = calcForecast(
      totalPages: project.totalPages,
      totalDays: totalDays,
      projectStartDate: project.startDate,
      processIds: processes.map((p) => p.id).toList(),
      processDateCounts: processDateCounts,
      planRatios: project.planRatios,
    );

    // 全体の予測日数
    String overallInfo = '';
    if (forecast.isNotEmpty) {
      final lastFc = forecast.last;
      final totalForecastEndFrac = lastFc.startFrac + lastFc.widthFrac;
      final totalForecastDays = (totalForecastEndFrac * totalDays).ceil();
      final overUnder = totalForecastDays - totalDays;
      if (overUnder > 0) {
        overallInfo = '想定 ${totalForecastDays}日（${overUnder}日超過）';
      } else {
        overallInfo = '想定 ${totalForecastDays}日（${-overUnder}日の余裕）';
      }
    }

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'ペース分析',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 全体情報
          _InfoRow('経過日数', '$elapsed / $totalDays 日'),
          _InfoRow('残り日数', '$daysLeft 日'),
          if (overallInfo.isNotEmpty) _InfoRow('全体予測', overallInfo),
          const Divider(height: 20),

          // 工程別分析
          ...List.generate(processes.length, (i) {
            final proc = processes[i];
            final completed = completedMap[proc.id] ?? 0;
            final remaining = (project.totalPages - completed).clamp(0, project.totalPages);
            final color = colorFromHex(proc.color);
            final planDays =
                i < project.planRatios.length
                    ? (project.planRatios[i] * totalDays).round()
                    : 0;

            // デモ版準拠のペース計算
            final dateCounts = processDateCounts[proc.id] ?? {};
            final pace = calcProcessPace(
              projectStartDate: project.startDate,
              dateCounts: dateCounts,
              isFirstProcess: i == 0,
            );

            String paceText;
            String statusText;
            Color statusColor;

            if (completed == 0) {
              paceText = '未着手（計画${planDays}日）';
              statusText = '計画通り';
              statusColor = AppTheme.textLight;
            } else if (completed >= project.totalPages) {
              paceText = '完了';
              statusText = '完了';
              statusColor = const Color(0xFF8EBB9E);
            } else if (pace == null) {
              // シール1個だけ = ペース計算不可
              paceText = '${completed}P済';
              statusText = '—';
              statusColor = AppTheme.textLight;
            } else {
              final forecastTotal =
                  (project.totalPages / pace.pace).ceil();
              final forecastRemaining =
                  remaining > 0 ? (remaining / pace.pace).ceil() : 0;
              final deviation = forecastTotal - planDays;

              paceText =
                  '${pace.pace.toStringAsFixed(1)} P/日';

              if (deviation > 0) {
                statusText = '${deviation}日超過';
                statusColor = Colors.redAccent;
              } else {
                statusText = '${-deviation}日余裕';
                statusColor = const Color(0xFF8EBB9E);
              }

              // 残りページの情報を追加
              if (remaining > 0) {
                paceText += '  残${forecastRemaining}日';
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(proc.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Text(
                      proc.label,
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.textColor),
                    ),
                  ),
                  Text(
                    '$completed/${project.totalPages}',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: Text(
                      paceText,
                      style:
                          TextStyle(fontSize: 10, color: AppTheme.textLight),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          Flexible(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
