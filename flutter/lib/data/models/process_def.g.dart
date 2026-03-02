// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_def.dart';

class ProcessDefAdapter extends TypeAdapter<ProcessDef> {
  @override
  final int typeId = 1;

  @override
  ProcessDef read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessDef(
      id: fields[0] as String,
      label: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessDef obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessDefAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
