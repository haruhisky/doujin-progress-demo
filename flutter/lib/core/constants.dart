import 'package:flutter/material.dart';

/// デフォルト工程定義
class DefaultProcesses {
  static const List<Map<String, String>> processes = [
    {'id': 'name', 'label': 'ネーム', 'icon': '📝', 'color': '#D4A0B9'},
    {'id': 'rough', 'label': '下書き', 'icon': '✏️', 'color': '#D4BC8A'},
    {'id': 'ink', 'label': 'ペン入れ', 'icon': '🖊️', 'color': '#8EB5C9'},
    {'id': 'finish', 'label': '仕上げ', 'icon': '✨', 'color': '#8EBB9E'},
  ];
}

/// 工程カラーパレット（くすみ版）
class ProcessColors {
  static const Color name = Color(0xFFD4A0B9);
  static const Color rough = Color(0xFFD4BC8A);
  static const Color ink = Color(0xFF8EB5C9);
  static const Color finish = Color(0xFF8EBB9E);

  /// 追加色（ユーザーが工程を追加する場合）
  static const List<Color> extras = [
    Color(0xFFB8A0C9),
    Color(0xFFC9A0A0),
    Color(0xFFA0C2B8),
    Color(0xFFC2B8A0),
  ];

  static const List<String> extraHexes = [
    '#B8A0C9',
    '#C9A0A0',
    '#A0C2B8',
    '#C2B8A0',
  ];

  static Color fromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

/// アイコン候補（工程設定で選べる絵文字）
class ProcessIcons {
  static const List<String> all = [
    '📝', '✏️', '🖊️', '✨', '🎨', '📐', '🖌️', '💬',
    '📄', '📖', '🔍', '🎯', '⭐', '💡', '📦', '🏷️',
  ];
}

/// デイリータスクのデフォルトカラー
const String kDailyTaskDefaultColor = '#B8C5D6';

/// イベントタスクのデフォルトカラー
const String kEventTaskDefaultColor = '#C9B8A8';
