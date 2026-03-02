import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/gantt/gantt_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/settings/settings_screen.dart';
import 'providers/navigation_provider.dart';

class WantapApp extends ConsumerWidget {
  const WantapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeScreen(),
          GanttScreen(),
          CalendarScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(navigationProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            activeIcon: Icon(Icons.pets, size: 28),
            label: '今日の進捗',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart, size: 28),
            label: 'ガント',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month, size: 28),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings, size: 28),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
