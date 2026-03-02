import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';

/// 日付詳細パネル
class DayDetail extends ConsumerWidget {
  final DateTime date;
  final VoidCallback onAddEvent;

  const DayDetail({
    super.key,
    required this.date,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = formatDate(date);
    final projects = ref.watch(projectsProvider);
    final dailyTasks = ref.watch(dailyTasksProvider);
    final eventTasks = ref.watch(eventTasksProvider);

    final todayEvents =
        eventTasks.where((e) => e.date == dateStr).toList();

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatDateJp(date),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddEvent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        'イベント',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 継起タスクの記録
          ...projects.map((project) {
            final logs = project.logsForDate(dateStr);
            if (logs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorFromHex(project.color),
                  ),
                ),
                const SizedBox(height: 4),
                ...logs.map((log) {
                  final proc = project.processes
                      .where((p) => p.id == log.process)
                      .toList();
                  final label = proc.isNotEmpty ? proc.first.label : log.process;
                  final icon = proc.isNotEmpty ? proc.first.icon : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$label: ${log.count}ページ',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textColor),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            );
          }),

          // デイリータスク
          ...dailyTasks.map((task) {
            final done = task.completedForDate(dateStr);
            if (done == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 12,
                      color: colorFromHex(task.color)),
                  const SizedBox(width: 4),
                  Text(
                    '${task.label}: $done/${task.count}回',
                    style: TextStyle(fontSize: 12, color: AppTheme.textColor),
                  ),
                ],
              ),
            );
          }),

          // イベントタスク
          ...todayEvents.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.event,
                      size: 12,
                      color: colorFromHex(task.color),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              )),

          // 何もない日
          if (_isEmpty(projects, dailyTasks, todayEvents, dateStr))
            Text(
              '記録なし',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
        ],
      ),
    );
  }

  bool _isEmpty(List projects, List dailyTasks, List todayEvents,
      String dateStr) {
    for (final p in projects) {
      if (p.logsForDate(dateStr).isNotEmpty) return false;
    }
    for (final d in dailyTasks) {
      if (d.completedForDate(dateStr) > 0) return false;
    }
    if (todayEvents.isNotEmpty) return false;
    return true;
  }
}
