// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task.dart';

class DailyTaskAdapter extends TypeAdapter<DailyTask> {
  @override
  final int typeId = 3;

  @override
  DailyTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTask(
      id: fields[0] as String,
      label: fields[1] as String,
      count: fields[2] as int,
      color: fields[3] as String,
      completionLog: fields.containsKey(4)
          ? (fields[4] as Map).cast<String, int>()
          : <String, int>{},
    );
  }

  @override
  void write(BinaryWriter writer, DailyTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.completionLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
