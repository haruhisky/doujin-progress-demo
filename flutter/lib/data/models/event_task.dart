import 'package:hive/hive.dart';

part 'event_task.g.dart';

@HiveType(typeId: 4)
class EventTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String date;

  @HiveField(3)
  String color;

  @HiveField(4)
  bool completed;

  EventTask({
    required this.id,
    required this.label,
    required this.date,
    required this.color,
    this.completed = false,
  });

  EventTask copyWith({
    String? id,
    String? label,
    String? date,
    String? color,
    bool? completed,
  }) {
    return EventTask(
      id: id ?? this.id,
      label: label ?? this.label,
      date: date ?? this.date,
      color: color ?? this.color,
      completed: completed ?? this.completed,
    );
  }
}
