import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 現在選択中のBottomNavigationBarタブインデックス
final navigationProvider = StateProvider<int>((ref) => 0);
