import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// カレンダーの日セル（ドット表示）
class DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool hasStickerActivity;
  final bool hasDailyActivity;
  final bool hasEventActivity;

  const DayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    this.hasStickerActivity = false,
    this.hasDailyActivity = false,
    this.hasEventActivity = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withOpacity(0.15)
            : isToday
                ? AppTheme.primary.withOpacity(0.06)
                : null,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: isToday ? AppTheme.primary : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 2),
          // 活動ドット
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasStickerActivity)
                _dot(AppTheme.primary),
              if (hasDailyActivity)
                _dot(AppTheme.secondary),
              if (hasEventActivity)
                _dot(AppTheme.tertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
