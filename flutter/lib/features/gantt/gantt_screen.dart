import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project_tabs.dart';
import 'widgets/gantt_chart.dart';
import 'widgets/pace_analysis.dart';

class GanttScreen extends ConsumerWidget {
  const GanttScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(activeProjectProvider);

    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.secondary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'ガントチャート',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
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

          // コンテンツ
          Expanded(
            child: project == null
                ? Center(
                    child: Text(
                      'プロジェクトを選択してください',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // ガントチャート（画面幅に収める）
                      Container(
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(8),
                        child: GanttChart(
                          project: project,
                          onRatiosChanged: (ratios) {
                            ref
                                .read(projectsProvider.notifier)
                                .updatePlanRatios(project.id, ratios);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ペース分析
                      PaceAnalysis(project: project),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
