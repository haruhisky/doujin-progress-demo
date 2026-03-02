import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/project_provider.dart';

/// ヘッダーのプロジェクト切替タブ
class ProjectTabs extends ConsumerWidget {
  const ProjectTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final activeId = ref.watch(activeProjectIdProvider);

    if (projects.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final project = projects[index];
          final isActive = project.id == activeId;
          final color = colorFromHex(project.color);

          return GestureDetector(
            onTap: () {
              ref.read(activeProjectIdProvider.notifier).state = project.id;
              ref.read(projectRepositoryProvider).activeProjectId = project.id;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : AppTheme.borderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Text(
                project.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? color : AppTheme.textLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
