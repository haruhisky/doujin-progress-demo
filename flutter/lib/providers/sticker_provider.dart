import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sticker_log.dart';
import '../core/utils.dart';
import 'project_provider.dart';

/// 今日の日付
final todayProvider = Provider<String>((ref) => todayStr());

/// アクティブプロジェクトの今日のシールログ
final todayStickerLogsProvider = Provider<List<StickerLog>>((ref) {
  final project = ref.watch(activeProjectProvider);
  final today = ref.watch(todayProvider);
  if (project == null) return [];
  return project.logsForDate(today);
});

/// アクティブプロジェクトの工程別完了数
final completedByProcessProvider = Provider<Map<String, int>>((ref) {
  final project = ref.watch(activeProjectProvider);
  if (project == null) return {};
  return project.completedByProcess;
});
