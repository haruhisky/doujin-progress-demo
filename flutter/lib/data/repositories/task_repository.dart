import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/daily_task.dart';
import '../models/event_task.dart';

class TaskRepository {
  Box<DailyTask> get _dailyBox => Hive.box<DailyTask>('dailyTasks');
  Box<EventTask> get _eventBox => Hive.box<EventTask>('eventTasks');

  // ── デイリータスク ──

  List<DailyTask> getAllDailyTasks() => _dailyBox.values.toList();

  Future<DailyTask> createDailyTask({
    required String label,
    required int count,
    required String color,
  }) async {
    final id = const Uuid().v4();
    final task = DailyTask(id: id, label: label, count: count, color: color);
    await _dailyBox.put(id, task);
    return task;
  }

  Future<void> updateDailyTask(DailyTask task) async {
    await _dailyBox.put(task.id, task);
  }

  Future<void> deleteDailyTask(String id) async {
    await _dailyBox.delete(id);
  }

  /// デイリータスクの達成を記録
  Future<void> completeDailySlot(String taskId, String date) async {
    final task = _dailyBox.get(taskId);
    if (task == null) return;
    final current = task.completedForDate(date);
    if (current < task.count) {
      task.completionLog[date] = current + 1;
      await _dailyBox.put(taskId, task);
    }
  }

  /// デイリータスクの達成を取消
  Future<void> uncompleteDailySlot(String taskId, String date) async {
    final task = _dailyBox.get(taskId);
    if (task == null) return;
    final current = task.completedForDate(date);
    if (current > 0) {
      task.completionLog[date] = current - 1;
      await _dailyBox.put(taskId, task);
    }
  }

  // ── イベントタスク ──

  List<EventTask> getAllEventTasks() => _eventBox.values.toList();

  List<EventTask> getEventTasksForDate(String date) {
    return _eventBox.values.where((t) => t.date == date).toList();
  }

  Future<EventTask> createEventTask({
    required String label,
    required String date,
    required String color,
  }) async {
    final id = const Uuid().v4();
    final task = EventTask(id: id, label: label, date: date, color: color);
    await _eventBox.put(id, task);
    return task;
  }

  Future<void> updateEventTask(EventTask task) async {
    await _eventBox.put(task.id, task);
  }

  Future<void> deleteEventTask(String id) async {
    await _eventBox.delete(id);
  }

  Future<void> toggleEventTaskCompletion(String taskId) async {
    final task = _eventBox.get(taskId);
    if (task == null) return;
    task.completed = !task.completed;
    await _eventBox.put(taskId, task);
  }
}
