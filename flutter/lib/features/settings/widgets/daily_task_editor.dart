import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../providers/task_provider.dart';

/// デイリータスク編集カード
class DailyTaskEditor extends ConsumerWidget {
  const DailyTaskEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(dailyTasksProvider);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 18, color: AppTheme.secondary),
              const SizedBox(width: 6),
              Text(
                'デイリータスク',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddForm(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 2),
                      Text(
                        '追加',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.secondary,
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

          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'デイリータスクなし',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ),
            )
          else
            ...tasks.map((task) {
              final color = colorFromHex(task.color);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${task.label} (${task.count}回/日)',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(dailyTasksProvider.notifier).delete(task.id);
                      },
                      child: Icon(Icons.close,
                          size: 16, color: AppTheme.textLight),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showAddForm(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '1');
    String selectedColor = kDailyTaskDefaultColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('デイリータスクを追加',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'タスク名'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '1日の回数'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  kDailyTaskDefaultColor,
                  '#D4A0B9',
                  '#8EB5C9',
                  '#8EBB9E',
                  '#D4BC8A',
                ].map((hex) {
                  final c = colorFromHex(hex);
                  final isSelected = hex == selectedColor;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.textColor, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final label = labelCtrl.text.trim();
                    final count = int.tryParse(countCtrl.text) ?? 1;
                    if (label.isEmpty) return;
                    ref.read(dailyTasksProvider.notifier).create(
                          label: label,
                          count: count,
                          color: selectedColor,
                        );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('追加'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
