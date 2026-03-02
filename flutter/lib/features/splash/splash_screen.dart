import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// スプラッシュ画面（データ読み込み中に表示）
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アプリアイコン
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/new_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '同人わんたっぷ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'できた分だけ、ポンっ',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
