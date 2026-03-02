import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/day_cell.dart';
import 'widgets/day_detail.dart';
import 'widgets/event_add_form.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final dailyTasks = ref.watch(dailyTasksProvider);
    final eventTasks = ref.watch(eventTasksProvider);

    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: AppTheme.tertiary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'カレンダー',
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
              children: [
                // カレンダー
                TableCalendar(
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) =>
                      _selectedDay != null && isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focused) {
                    _focusedDay = focused;
                  },
                  locale: 'ja_JP',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left,
                        color: AppTheme.textLight),
                    rightChevronIcon: Icon(Icons.chevron_right,
                        color: AppTheme.textLight),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle:
                        TextStyle(fontSize: 11, color: AppTheme.textLight),
                    weekendStyle:
                        TextStyle(fontSize: 11, color: AppTheme.primary.withOpacity(0.6)),
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: EdgeInsets.all(1),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focused) =>
                        _buildDayCell(day, false, false, projects,
                            dailyTasks, eventTasks),
                    todayBuilder: (context, day, focused) =>
                        _buildDayCell(day, true, false, projects,
                            dailyTasks, eventTasks),
                    selectedBuilder: (context, day, focused) =>
                        _buildDayCell(day, isSameDay(day, DateTime.now()),
                            true, projects, dailyTasks, eventTasks),
                  ),
                  rowHeight: 52,
                ),

                // プロジェクト期間マーカー
                if (projects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      children: projects.map((p) {
                        final color = colorFromHex(p.color);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${p.name}  ${p.startDate} 〜 ${p.deadline}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // 日付詳細
                if (_selectedDay != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: DayDetail(
                      date: _selectedDay!,
                      onAddEvent: () => _showEventAddForm(context),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    bool isToday,
    bool isSelected,
    List projects,
    List dailyTasks,
    List eventTasks,
  ) {
    final dateStr = formatDate(day);

    bool hasStickerActivity = false;
    for (final p in projects) {
      if (p.logsForDate(dateStr).isNotEmpty) {
        hasStickerActivity = true;
        break;
      }
    }

    bool hasDailyActivity = false;
    for (final d in dailyTasks) {
      if (d.completedForDate(dateStr) > 0) {
        hasDailyActivity = true;
        break;
      }
    }

    final hasEventActivity =
        eventTasks.any((e) => e.date == dateStr);

    return DayCell(
      day: day,
      isToday: isToday,
      isSelected: isSelected,
      hasStickerActivity: hasStickerActivity,
      hasDailyActivity: hasDailyActivity,
      hasEventActivity: hasEventActivity,
    );
  }

  void _showEventAddForm(BuildContext context) {
    if (_selectedDay == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EventAddForm(
        date: _selectedDay!,
        onSave: (label, date, color) {
          ref
              .read(eventTasksProvider.notifier)
              .create(label: label, date: date, color: color);
        },
      ),
    );
  }
}
