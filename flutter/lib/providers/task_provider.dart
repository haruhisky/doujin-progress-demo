import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_task.dart';
import '../data/models/event_task.dart';
import '../data/repositories/task_repository.dart';
import '../core/utils.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// 全デイリータスク
final dailyTasksProvider =
    StateNotifierProvider<DailyTasksNotifier, List<DailyTask>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return DailyTasksNotifier(repo);
});

/// 全イベントタスク
final eventTasksProvider =
    StateNotifierProvider<EventTasksNotifier, List<EventTask>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return EventTasksNotifier(repo);
});

/// 今日のイベントタスク
final todayEventTasksProvider = Provider<List<EventTask>>((ref) {
  final events = ref.watch(eventTasksProvider);
  final today = todayStr();
  return events.where((e) => e.date == today).toList();
});

class DailyTasksNotifier extends StateNotifier<List<DailyTask>> {
  final TaskRepository _repo;

  DailyTasksNotifier(this._repo) : super(_repo.getAllDailyTasks());

  void refresh() => state = _repo.getAllDailyTasks();

  Future<void> create({
    required String label,
    required int count,
    required String color,
  }) async {
    await _repo.createDailyTask(label: label, count: count, color: color);
    state = [..._repo.getAllDailyTasks()];
  }

  Future<void> update(DailyTask task) async {
    await _repo.updateDailyTask(task);
    state = [..._repo.getAllDailyTasks()];
  }

  Future<void> delete(String id) async {
    await _repo.deleteDailyTask(id);
    state = [..._repo.getAllDailyTasks()];
  }

  Future<void> completeSlot(String taskId, String date) async {
    await _repo.completeDailySlot(taskId, date);
    state = [..._repo.getAllDailyTasks()];
  }

  Future<void> uncompleteSlot(String taskId, String date) async {
    await _repo.uncompleteDailySlot(taskId, date);
    state = [..._repo.getAllDailyTasks()];
  }
}

class EventTasksNotifier extends StateNotifier<List<EventTask>> {
  final TaskRepository _repo;

  EventTasksNotifier(this._repo) : super(_repo.getAllEventTasks());

  void refresh() => state = _repo.getAllEventTasks();

  Future<void> create({
    required String label,
    required String date,
    required String color,
  }) async {
    await _repo.createEventTask(label: label, date: date, color: color);
    state = [..._repo.getAllEventTasks()];
  }

  Future<void> update(EventTask task) async {
    await _repo.updateEventTask(task);
    state = [..._repo.getAllEventTasks()];
  }

  Future<void> delete(String id) async {
    await _repo.deleteEventTask(id);
    state = [..._repo.getAllEventTasks()];
  }

  Future<void> toggleCompletion(String taskId) async {
    await _repo.toggleEventTaskCompletion(taskId);
    state = [..._repo.getAllEventTasks()];
  }
}
