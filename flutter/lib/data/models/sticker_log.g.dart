// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_log.dart';

class StickerLogAdapter extends TypeAdapter<StickerLog> {
  @override
  final int typeId = 2;

  @override
  StickerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickerLog(
      process: fields[0] as String,
      date: fields[1] as String,
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StickerLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.process)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
