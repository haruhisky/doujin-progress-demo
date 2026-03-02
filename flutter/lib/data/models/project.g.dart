// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      totalPages: fields[2] as int,
      startDate: fields[3] as String,
      deadline: fields[4] as String,
      color: fields[5] as String,
      processes: (fields[6] as List).cast<ProcessDef>(),
      planRatios: (fields[7] as List).cast<double>(),
      stickerLog: (fields[8] as List).cast<StickerLog>(),
      createdAt: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalPages)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.processes)
      ..writeByte(7)
      ..write(obj.planRatios)
      ..writeByte(8)
      ..write(obj.stickerLog)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
