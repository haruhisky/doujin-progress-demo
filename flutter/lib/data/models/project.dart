import 'package:hive/hive.dart';
import 'process_def.dart';
import 'sticker_log.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int totalPages;

  @HiveField(3)
  String startDate;

  @HiveField(4)
  String deadline;

  @HiveField(5)
  String color;

  @HiveField(6)
  List<ProcessDef> processes;

  @HiveField(7)
  List<double> planRatios;

  @HiveField(8)
  List<StickerLog> stickerLog;

  @HiveField(9)
  String createdAt;

  Project({
    required this.id,
    required this.name,
    required this.totalPages,
    required this.startDate,
    required this.deadline,
    required this.color,
    required this.processes,
    required this.planRatios,
    required this.stickerLog,
    required this.createdAt,
  });

  /// 工程ごとの完了ページ数を集計
  Map<String, int> get completedByProcess {
    final map = <String, int>{};
    for (final log in stickerLog) {
      map[log.process] = (map[log.process] ?? 0) + log.count;
    }
    return map;
  }

  /// 全工程の合計完了ページ数
  int get totalCompleted {
    int sum = 0;
    for (final log in stickerLog) {
      sum += log.count;
    }
    return sum;
  }

  /// 特定日付のシールログを取得
  List<StickerLog> logsForDate(String date) {
    return stickerLog.where((l) => l.date == date).toList();
  }

  /// 工程ごとの日別シール数マップ { processId: { date: count } }
  Map<String, Map<String, int>> get processDateCounts {
    final map = <String, Map<String, int>>{};
    for (final log in stickerLog) {
      map.putIfAbsent(log.process, () => <String, int>{});
      map[log.process]![log.date] =
          (map[log.process]![log.date] ?? 0) + log.count;
    }
    return map;
  }

  Project copyWith({
    String? id,
    String? name,
    int? totalPages,
    String? startDate,
    String? deadline,
    String? color,
    List<ProcessDef>? processes,
    List<double>? planRatios,
    List<StickerLog>? stickerLog,
    String? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPages: totalPages ?? this.totalPages,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      processes: processes ?? this.processes,
      planRatios: planRatios ?? this.planRatios,
      stickerLog: stickerLog ?? this.stickerLog,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
