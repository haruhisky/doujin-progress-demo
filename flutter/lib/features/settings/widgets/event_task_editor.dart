import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../providers/task_provider.dart';

/// イベントタスク編集カード
class EventTaskEditor extends ConsumerWidget {
  const EventTaskEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(eventTasksProvider);

    // 日付でソート
    final sortedTasks = List.from(tasks)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 18, color: AppTheme.tertiary),
              const SizedBox(width: 6),
              Text(
                'イベントタスク',
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
                    color: AppTheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '追加',
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

          if (sortedTasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'イベントタスクなし',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ),
            )
          else
            ...sortedTasks.map((task) {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textColor,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          Text(
                            task.date,
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    if (task.completed)
                      Icon(Icons.check_circle,
                          size: 16, color: color),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(eventTasksProvider.notifier).delete(task.id);
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
    DateTime selectedDate = DateTime.now();
    String selectedColor = kEventTaskDefaultColor;

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
              Text('イベントタスクを追加',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'イベント名'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('ja'),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        formatDateJp(selectedDate),
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  kEventTaskDefaultColor,
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
                    if (label.isEmpty) return;
                    ref.read(eventTasksProvider.notifier).create(
                          label: label,
                          date: formatDate(selectedDate),
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
