import 'dart:math';
import 'package:flutter/material.dart';

/// 日付を YYYY-MM-DD 文字列に変換
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// YYYY-MM-DD 文字列を DateTime に変換
DateTime parseDate(String dateStr) {
  final parts = dateStr.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// 今日の日付文字列
String todayStr() => formatDate(DateTime.now());

/// 2つの日付間の日数差
int daysBetween(DateTime from, DateTime to) {
  final f = DateTime(from.year, from.month, from.day);
  final t = DateTime(to.year, to.month, to.day);
  return t.difference(f).inDays;
}

/// ペース計算結果
class PaceResult {
  final double pace; // pages per day
  final int totalStickers;
  final int days;
  PaceResult({required this.pace, required this.totalStickers, required this.days});
}

/// 工程ごとのペース計算（デモ版準拠）
/// dateCounts: 該当工程の { "2026-03-01": 3, "2026-03-02": 5 }
/// 最初の工程はプロジェクト開始日から、それ以外は最初のシール日から計算
/// pace = totalStickers / elapsedDays (ページ/日)
PaceResult? calcProcessPace({
  required String projectStartDate,
  required Map<String, int> dateCounts,
  required bool isFirstProcess,
}) {
  if (dateCounts.isEmpty) return null;

  int totalStickers = dateCounts.values.fold(0, (a, b) => a + b);
  if (totalStickers <= 0) return null;

  final dates = dateCounts.keys.toList()..sort();
  final lastDate = parseDate(dates.last);

  DateTime periodStart;
  if (isFirstProcess) {
    periodStart = parseDate(projectStartDate);
  } else {
    periodStart = parseDate(dates.first);
  }

  final days = max(1, daysBetween(periodStart, lastDate) + 1);
  final pace = totalStickers / days;

  return PaceResult(pace: pace, totalStickers: totalStickers, days: days);
}

/// 旧calcPace（後方互換用）
double? calcPace({
  required String startDate,
  required int completedCount,
}) {
  if (completedCount <= 0) return null;
  final start = parseDate(startDate);
  final now = DateTime.now();
  final elapsed = daysBetween(start, now);
  final effectiveDays = elapsed < 1 ? 1 : elapsed;
  return effectiveDays / completedCount;
}

/// 想定完了日を計算
DateTime? estimateCompletionDate({
  required String startDate,
  required int completedCount,
  required int totalCount,
}) {
  final pace = calcPace(startDate: startDate, completedCount: completedCount);
  if (pace == null) return null;
  final remaining = totalCount - completedCount;
  if (remaining <= 0) return DateTime.now();
  final daysNeeded = (remaining * pace).ceil();
  return DateTime.now().add(Duration(days: daysNeeded));
}

/// ガントチャート予測データ
class ForecastItem {
  final double startFrac;
  final double widthFrac;
  final bool hasPace;
  final double? forecastDays;
  ForecastItem({
    required this.startFrac,
    required this.widthFrac,
    required this.hasPace,
    this.forecastDays,
  });
}

/// ガントチャート用の予測データを計算
/// 各工程の予測を連鎖的に計算（前工程終了後に次工程開始）
/// 未着手工程は計画日数をそのまま使用
List<ForecastItem> calcForecast({
  required int totalPages,
  required int totalDays,
  required String projectStartDate,
  required List<String> processIds,
  required Map<String, Map<String, int>> processDateCounts,
  required List<double> planRatios,
}) {
  if (totalDays <= 0) return [];

  final forecastData = <ForecastItem>[];
  double chainEndDayOffset = 0;

  for (int i = 0; i < processIds.length; i++) {
    final dateCounts = processDateCounts[processIds[i]] ?? {};
    final pace = calcProcessPace(
      projectStartDate: projectStartDate,
      dateCounts: dateCounts,
      isFirstProcess: i == 0,
    );

    if (pace != null) {
      // ペースデータあり: 実績ベースの予測
      final forecastDays = totalPages / pace.pace;
      final startFrac = chainEndDayOffset / totalDays;
      final widthFrac = forecastDays / totalDays;
      forecastData.add(ForecastItem(
        startFrac: startFrac,
        widthFrac: widthFrac,
        hasPace: true,
        forecastDays: forecastDays,
      ));
      chainEndDayOffset += forecastDays;
    } else {
      // 未着手: 計画日数をそのまま使用
      final planRatio = i < planRatios.length
          ? planRatios[i]
          : 1.0 / processIds.length;
      final planDays = planRatio * totalDays;
      final startFrac = chainEndDayOffset / totalDays;
      final widthFrac = planDays / totalDays;
      forecastData.add(ForecastItem(
        startFrac: startFrac,
        widthFrac: widthFrac,
        hasPace: false,
        forecastDays: planDays,
      ));
      chainEndDayOffset += planDays;
    }
  }

  return forecastData;
}

/// Hex文字列 → Color
Color colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

/// Color → Hex文字列
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}

/// 日本語の曜日
String weekdayJp(int weekday) {
  const days = ['月', '火', '水', '木', '金', '土', '日'];
  return days[weekday - 1];
}

/// 日付の表示用フォーマット（3月2日(月)）
String formatDateJp(DateTime date) {
  return '${date.month}月${date.day}日(${weekdayJp(date.weekday)})';
}
