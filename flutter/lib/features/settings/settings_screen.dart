import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'widgets/project_manager.dart';
import 'widgets/process_editor.dart';
import 'widgets/daily_task_editor.dart';
import 'widgets/event_task_editor.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.settings, color: AppTheme.textLight, size: 22),
                const SizedBox(width: 8),
                Text(
                  '設定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ProjectManager(),
                SizedBox(height: 12),
                DailyTaskEditor(),
                SizedBox(height: 12),
                EventTaskEditor(),
                SizedBox(height: 12),
                ProcessEditor(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
