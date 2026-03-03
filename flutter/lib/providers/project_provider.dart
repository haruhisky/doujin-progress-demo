import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/project.dart';
import '../data/models/process_def.dart';
import '../data/repositories/project_repository.dart';

/// リポジトリのシングルトン
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

/// 全プロジェクトリスト
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return ProjectsNotifier(repo, ref);
});

/// アクティブプロジェクトID
final activeProjectIdProvider = StateProvider<String?>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.activeProjectId;
});

/// アクティブプロジェクト（派生）
final activeProjectProvider = Provider<Project?>((ref) {
  final projects = ref.watch(projectsProvider);
  final activeId = ref.watch(activeProjectIdProvider);
  if (activeId == null) return null;
  try {
    return projects.firstWhere((p) => p.id == activeId);
  } catch (_) {
    return projects.isNotEmpty ? projects.first : null;
  }
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _repo;
  final Ref _ref;

  ProjectsNotifier(this._repo, this._ref) : super(_repo.getAll());

  /// Hiveのオブジェクトは同一参照なので、copyWithで新しいインスタンスを作り
  /// Riverpod の Provider（activeProjectProvider等）が変更を検出できるようにする
  void _notify() {
    state = _repo.getAll().map((p) => p.copyWith()).toList();
  }

  void refresh() => _notify();

  Future<Project> create({
    required String name,
    required int totalPages,
    required String startDate,
    required String deadline,
    String color = '#D4A0B9',
  }) async {
    final project = await _repo.create(
      name: name,
      totalPages: totalPages,
      startDate: startDate,
      deadline: deadline,
      color: color,
    );
    _notify();
    return project;
  }

  Future<void> update(Project project) async {
    await _repo.update(project);
    _notify();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    // 削除後のアクティブIDをProviderに同期
    _ref.read(activeProjectIdProvider.notifier).state = _repo.activeProjectId;
    _notify();
  }

  Future<void> addSticker(String projectId, String processId, String date) async {
    await _repo.addSticker(projectId, processId, date);
    _notify();
  }

  Future<void> removeSticker(String projectId, String processId, String date) async {
    await _repo.removeSticker(projectId, processId, date);
    _notify();
  }

  Future<void> updatePlanRatios(String projectId, List<double> ratios) async {
    final project = _repo.getById(projectId);
    if (project == null) return;
    project.planRatios = ratios;
    await _repo.update(project);
    _notify();
  }

  Future<void> updateProcesses(
      String projectId, List<ProcessDef> processes) async {
    final project = _repo.getById(projectId);
    if (project == null) return;
    project.processes = processes;
    if (project.planRatios.length != processes.length) {
      project.planRatios =
          List.filled(processes.length, 1.0 / processes.length);
    }
    await _repo.update(project);
    _notify();
  }

  Future<void> ensureDefaultProject() async {
    await _repo.ensureDefaultProject();
    _notify();
  }
}
