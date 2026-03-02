import 'package:hive/hive.dart';

part 'sticker_log.g.dart';

@HiveType(typeId: 2)
class StickerLog extends HiveObject {
  @HiveField(0)
  String process;

  @HiveField(1)
  String date;

  @HiveField(2)
  int count;

  StickerLog({
    required this.process,
    required this.date,
    required this.count,
  });

  StickerLog copyWith({
    String? process,
    String? date,
    int? count,
  }) {
    return StickerLog(
      process: process ?? this.process,
      date: date ?? this.date,
      count: count ?? this.count,
    );
  }
}
