import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/project_provider.dart';
import '../../providers/sticker_provider.dart';
import '../../providers/task_provider.dart';
import '../../data/models/daily_task.dart';
import '../../widgets/project_tabs.dart';
import 'widgets/tap_grid.dart';
import 'widgets/daily_event_row.dart';

/// デイリータスクを3つまで横並びにする
List<Widget> _buildDailyTaskRows(
    List<DailyTask> tasks, String today, WidgetRef ref) {
  final rows = <Widget>[];
  // 3つずつグループにする
  for (int i = 0; i < tasks.length; i += 3) {
    final chunk = tasks.sublist(i, (i + 3).clamp(0, tasks.length));
    rows.add(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...chunk.map((task) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: task != chunk.last ? 8 : 0,
                  ),
                  child: DailyTaskRow(
                    task: task,
                    date: today,
                    onTap: () => ref
                        .read(dailyTasksProvider.notifier)
                        .completeSlot(task.id, today),
                    onUntap: () => ref
                        .read(dailyTasksProvider.notifier)
                        .uncompleteSlot(task.id, today),
                  ),
                ),
              )),
          // 3列に満たない場合、空のExpandedで埋める
          ...List.generate(3 - chunk.length, (_) => const Expanded(child: SizedBox())),
        ],
      ),
    ));
  }
  return rows;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(activeProjectProvider);
    final today = ref.watch(todayProvider);
    final dailyTasks = ref.watch(dailyTasksProvider);
    final todayEvents = ref.watch(todayEventTasksProvider);

    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.pets, color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '今日の進捗',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatDateJp(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // プロジェクトタブ
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ProjectTabs(),
          ),

          // メインコンテンツ
          Expanded(
            child: project == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 48,
                            color: AppTheme.textLight.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'プロジェクトを作成してください',
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // 進捗サマリー
                      const _ProgressSummary(),
                      const SizedBox(height: 12),

                      // デイリータスク（3つまで横並び）
                      if (dailyTasks.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'デイリータスク',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                        ..._buildDailyTaskRows(dailyTasks, today, ref),
                        const SizedBox(height: 4),
                      ],

                      // イベントタスク
                      if (todayEvents.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'イベントタスク',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                        ...todayEvents.map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: EventTaskRow(
                                task: task,
                                onToggle: () => ref
                                    .read(eventTasksProvider.notifier)
                                    .toggleCompletion(task.id),
                              ),
                            )),
                        const SizedBox(height: 4),
                      ],

                      // 継起タスク（タップグリッド）
                      const TapGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// 進捗サマリー（Riverpodプロバイダを直接watchして即時更新を保証）
class _ProgressSummary extends ConsumerWidget {
  const _ProgressSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(activeProjectProvider);
    if (project == null) return const SizedBox.shrink();

    final completed = ref.watch(completedByProcessProvider);
    final total = project.totalPages;

    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ...project.processes.map((proc) {
            final count = completed[proc.id] ?? 0;
            final color = colorFromHex(proc.color);
            return Expanded(
              child: Column(
                children: [
                  Text(proc.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '/ $total',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
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
