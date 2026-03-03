import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/process_def.dart';
import '../models/sticker_log.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';

class ProjectRepository {
  static const _boxName = 'projects';
  static const _settingsBox = 'settings';
  static const _activeProjectKey = 'activeProjectId';

  Box<Project> get _box => Hive.box<Project>(_boxName);
  Box get _settings => Hive.box(_settingsBox);

  List<Project> getAll() => _box.values.toList();

  Project? getById(String id) {
    try {
      return _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  String? get activeProjectId =>
      _settings.get(_activeProjectKey) as String?;

  set activeProjectId(String? id) =>
      _settings.put(_activeProjectKey, id);

  Project? get activeProject {
    final id = activeProjectId;
    if (id == null) return null;
    return getById(id);
  }

  Future<Project> create({
    required String name,
    required int totalPages,
    required String startDate,
    required String deadline,
    String color = '#D4A0B9',
    List<ProcessDef>? processes,
  }) async {
    final id = const Uuid().v4();
    final procs = processes ??
        DefaultProcesses.processes
            .map((p) => ProcessDef(
                  id: p['id']!,
                  label: p['label']!,
                  icon: p['icon']!,
                  color: p['color']!,
                ))
            .toList();

    final project = Project(
      id: id,
      name: name,
      totalPages: totalPages,
      startDate: startDate,
      deadline: deadline,
      color: color,
      processes: procs,
      planRatios: List.filled(procs.length, 1.0 / procs.length),
      stickerLog: [],
      createdAt: formatDate(DateTime.now()),
    );

    await _box.put(id, project);

    // 最初のプロジェクトなら自動選択
    if (_box.length == 1) {
      activeProjectId = id;
    }

    return project;
  }

  Future<void> update(Project project) async {
    await _box.put(project.id, project);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    if (activeProjectId == id) {
      final remaining = getAll();
      activeProjectId = remaining.isNotEmpty ? remaining.first.id : null;
    }
  }

  /// シールを追加
  Future<void> addSticker(String projectId, String processId, String date) async {
    final project = getById(projectId);
    if (project == null) return;

    final existing = project.stickerLog
        .where((l) => l.process == processId && l.date == date)
        .toList();

    if (existing.isNotEmpty) {
      existing.first.count += 1;
    } else {
      project.stickerLog.add(StickerLog(
        process: processId,
        date: date,
        count: 1,
      ));
    }

    await update(project);
  }

  /// シールを削除（1つ）
  Future<void> removeSticker(String projectId, String processId, String date) async {
    final project = getById(projectId);
    if (project == null) return;

    final existing = project.stickerLog
        .where((l) => l.process == processId && l.date == date)
        .toList();

    if (existing.isNotEmpty) {
      if (existing.first.count > 1) {
        existing.first.count -= 1;
      } else {
        project.stickerLog.remove(existing.first);
      }
    }

    await update(project);
  }

  /// 過去シールを1つ削除（今日以外の最新日付のログから-1）
  Future<void> removeLatestSticker(String projectId, String processId) async {
    final project = getById(projectId);
    if (project == null) return;

    final today = todayStr();
    final pastLogs = project.stickerLog
        .where((l) => l.process == processId && l.date != today && l.count > 0)
        .toList();
    if (pastLogs.isEmpty) return;

    // 日付降順ソートして最新を取得
    pastLogs.sort((a, b) => b.date.compareTo(a.date));
    final latest = pastLogs.first;

    if (latest.count > 1) {
      latest.count -= 1;
    } else {
      project.stickerLog.remove(latest);
    }

    await update(project);
  }

  /// 過去シールを1つ追加（直近の過去日付に+1、なければ昨日に追加）
  Future<void> addPastSticker(String projectId, String processId) async {
    final project = getById(projectId);
    if (project == null) return;

    final today = todayStr();
    final pastLogs = project.stickerLog
        .where((l) => l.process == processId && l.date != today && l.count > 0)
        .toList();

    if (pastLogs.isNotEmpty) {
      pastLogs.sort((a, b) => b.date.compareTo(a.date));
      pastLogs.first.count += 1;
    } else {
      // 過去ログがなければ昨日の日付で作成
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      project.stickerLog.add(StickerLog(
        process: processId,
        date: formatDate(yesterday),
        count: 1,
      ));
    }

    await update(project);
  }

  /// デフォルトプロジェクトを作成（初回起動時）
  Future<void> ensureDefaultProject() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 60));
      await create(
        name: '新しい同人誌',
        totalPages: 24,
        startDate: formatDate(now),
        deadline: formatDate(deadline),
      );
    }
  }
}
