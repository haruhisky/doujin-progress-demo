import 'package:hive/hive.dart';

part 'daily_task.g.dart';

@HiveType(typeId: 3)
class DailyTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int count;

  @HiveField(3)
  String color;

  /// 日付ごとの達成数（キー: YYYY-MM-DD, 値: 達成数）
  @HiveField(4)
  Map<String, int> completionLog;

  DailyTask({
    required this.id,
    required this.label,
    required this.count,
    required this.color,
    Map<String, int>? completionLog,
  }) : completionLog = completionLog ?? {};

  int completedForDate(String date) => completionLog[date] ?? 0;

  DailyTask copyWith({
    String? id,
    String? label,
    int? count,
    String? color,
    Map<String, int>? completionLog,
  }) {
    return DailyTask(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
      color: color ?? this.color,
      completionLog: completionLog ?? Map.from(this.completionLog),
    );
  }
}
