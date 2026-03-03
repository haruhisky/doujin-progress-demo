import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'app.dart';
import 'features/splash/splash_screen.dart';
import 'data/models/project.dart';
import 'data/models/process_def.dart';
import 'data/models/sticker_log.dart';
import 'data/models/daily_task.dart';
import 'data/models/event_task.dart';
import 'data/repositories/project_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: WantapRoot(),
    ),
  );
}

class WantapRoot extends StatefulWidget {
  const WantapRoot({super.key});

  @override
  State<WantapRoot> createState() => _WantapRootState();
}

class _WantapRootState extends State<WantapRoot> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Hive 初期化
    await Hive.initFlutter();

    // TypeAdapter 登録
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(ProcessDefAdapter());
    Hive.registerAdapter(StickerLogAdapter());
    Hive.registerAdapter(DailyTaskAdapter());
    Hive.registerAdapter(EventTaskAdapter());

    // Box を開く
    await Hive.openBox<Project>('projects');
    await Hive.openBox<DailyTask>('dailyTasks');
    await Hive.openBox<EventTask>('eventTasks');
    await Hive.openBox('settings');

    // 日本語ロケール初期化
    await initializeDateFormatting('ja_JP', null);

    // デフォルトプロジェクトを作成（初回起動時）
    await ProjectRepository().ensureDefaultProject();

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '同人わんたっぷ',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
      ],
      locale: const Locale('ja'),
      home: _initialized ? const WantapApp() : const SplashScreen(),
    );
  }
}
