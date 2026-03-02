import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../data/models/daily_task.dart';
import '../../../data/models/event_task.dart';
import 'paw_painter.dart';

/// デイリータスク行
class DailyTaskRow extends StatelessWidget {
  final DailyTask task;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onUntap;

  const DailyTaskRow({
    super.key,
    required this.task,
    required this.date,
    required this.onTap,
    required this.onUntap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = task.completedForDate(date);
    final color = colorFromHex(task.color);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              Text(
                '$completed / ${task.count}',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 肉球スロット
          Wrap(
            spacing: 8,
            children: List.generate(task.count, (i) {
              final filled = i < completed;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (filled) {
                    onUntap();
                  } else {
                    onTap();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: filled
                        ? color.withOpacity(0.15)
                        : AppTheme.borderColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: filled
                          ? color.withOpacity(0.3)
                          : AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: filled
                      ? CustomPaint(
                          painter: PawPainter(color: color),
                          size: const Size(40, 40),
                        )
                      : Icon(
                          Icons.pets_outlined,
                          size: 18,
                          color: AppTheme.textLight.withOpacity(0.4),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// イベントタスク行
class EventTaskRow extends StatelessWidget {
  final EventTask task;
  final VoidCallback onToggle;

  const EventTaskRow({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(task.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: task.completed
                    ? color.withOpacity(0.15)
                    : AppTheme.borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: task.completed
                      ? color.withOpacity(0.3)
                      : AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: task.completed
                  ? Icon(Icons.check, size: 20, color: color)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    'イベント',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.event, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
