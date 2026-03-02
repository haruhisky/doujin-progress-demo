import 'package:hive/hive.dart';

part 'process_def.g.dart';

@HiveType(typeId: 1)
class ProcessDef extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String color;

  ProcessDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  ProcessDef copyWith({
    String? id,
    String? label,
    String? icon,
    String? color,
  }) {
    return ProcessDef(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
