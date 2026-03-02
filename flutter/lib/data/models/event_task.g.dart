// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_task.dart';

class EventTaskAdapter extends TypeAdapter<EventTask> {
  @override
  final int typeId = 4;

  @override
  EventTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventTask(
      id: fields[0] as String,
      label: fields[1] as String,
      date: fields[2] as String,
      color: fields[3] as String,
      completed: fields.containsKey(4) ? fields[4] as bool : false,
    );
  }

  @override
  void write(BinaryWriter writer, EventTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
