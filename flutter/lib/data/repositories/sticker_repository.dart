import '../models/sticker_log.dart';
import 'project_repository.dart';

/// シールログへの便利アクセスを提供するリポジトリ
class StickerRepository {
  final ProjectRepository _projectRepo;

  StickerRepository(this._projectRepo);

  /// 特定プロジェクト・日付のシールログを取得
  List<StickerLog> getLogsForDate(String projectId, String date) {
    final project = _projectRepo.getById(projectId);
    if (project == null) return [];
    return project.logsForDate(date);
  }

  /// 特定プロジェクト・工程の全日付のシール合計
  int getTotalForProcess(String projectId, String processId) {
    final project = _projectRepo.getById(projectId);
    if (project == null) return 0;
    return project.completedByProcess[processId] ?? 0;
  }

  /// 全日付にシールがある日のリストを返す
  List<String> getDatesWithStickers(String projectId) {
    final project = _projectRepo.getById(projectId);
    if (project == null) return [];
    return project.stickerLog.map((l) => l.date).toSet().toList()..sort();
  }
}
