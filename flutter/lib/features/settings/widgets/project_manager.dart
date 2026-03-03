import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../providers/project_provider.dart';

/// プロジェクト管理カード（一覧 + 追加 + 削除 + 切替 + 編集）
class ProjectManager extends ConsumerWidget {
  const ProjectManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final activeId = ref.watch(activeProjectIdProvider);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'プロジェクト管理',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddDialog(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 2),
                      Text(
                        '追加',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...projects.map((project) {
            final isActive = project.id == activeId;
            final color = colorFromHex(project.color);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  ref.read(activeProjectIdProvider.notifier).state = project.id;
                  ref.read(projectRepositoryProvider).activeProjectId =
                      project.id;
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? color.withOpacity(0.3)
                          : AppTheme.borderColor,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            Text(
                              '${project.totalPages}P  ${project.startDate} 〜 ${project.deadline}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Icon(Icons.check_circle, size: 18, color: color),
                      // 編集ボタン
                      GestureDetector(
                        onTap: () => _showEditDialog(context, ref, project.id),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.edit_outlined,
                              size: 16, color: AppTheme.textLight),
                        ),
                      ),
                      if (projects.length > 1)
                        GestureDetector(
                          onTap: () => _confirmDelete(
                              context, ref, project.id, project.name),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.close,
                                size: 16, color: AppTheme.textLight),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: '新しい同人誌');
    final pagesCtrl = TextEditingController(text: '24');
    DateTime startDate = DateTime.now();
    DateTime deadlineDate = DateTime.now().add(const Duration(days: 60));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('プロジェクトを追加',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'プロジェクト名'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pagesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '総ページ数'),
              ),
              const SizedBox(height: 12),
              // 開始日
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('ja'),
                  );
                  if (picked != null) {
                    setModalState(() => startDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('開始日',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textLight)),
                      ),
                      Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        formatDateJp(startDate),
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 締切日
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadlineDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('ja'),
                  );
                  if (picked != null) {
                    setModalState(() => deadlineDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('締切日',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textLight)),
                      ),
                      Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        formatDateJp(deadlineDate),
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final pages =
                        (int.tryParse(pagesCtrl.text) ?? 24).clamp(1, 9999);
                    if (name.isEmpty) return;
                    if (!startDate.isBefore(deadlineDate)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('開始日は締切日より前にしてください')),
                      );
                      return;
                    }
                    ref.read(projectsProvider.notifier).create(
                          name: name,
                          totalPages: pages,
                          startDate: formatDate(startDate),
                          deadline: formatDate(deadlineDate),
                        );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('作成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// プロジェクト編集ダイアログ（名前、ページ数、開始日、締切日）
  void _showEditDialog(BuildContext context, WidgetRef ref, String projectId) {
    final projects = ref.read(projectsProvider);
    final project =
        projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null) return;
    final nameCtrl = TextEditingController(text: project.name);
    final pagesCtrl = TextEditingController(text: project.totalPages.toString());
    DateTime startDate = parseDate(project.startDate);
    DateTime deadlineDate = parseDate(project.deadline);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('プロジェクトを編集',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'プロジェクト名'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pagesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '総ページ数'),
              ),
              const SizedBox(height: 12),
              // 開始日
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('ja'),
                  );
                  if (picked != null) {
                    setModalState(() => startDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('開始日',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textLight)),
                      ),
                      Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        formatDateJp(startDate),
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 締切日
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadlineDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('ja'),
                  );
                  if (picked != null) {
                    setModalState(() => deadlineDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('締切日',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textLight)),
                      ),
                      Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(
                        formatDateJp(deadlineDate),
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final pages =
                        (int.tryParse(pagesCtrl.text) ?? project.totalPages)
                            .clamp(1, 9999);
                    if (name.isEmpty) return;
                    if (!startDate.isBefore(deadlineDate)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('開始日は締切日より前にしてください')),
                      );
                      return;
                    }
                    project.name = name;
                    project.totalPages = pages;
                    project.startDate = formatDate(startDate);
                    project.deadline = formatDate(deadlineDate);
                    ref.read(projectsProvider.notifier).update(project);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プロジェクトを削除'),
        content: Text('「$name」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectsProvider.notifier).delete(id);
              Navigator.of(ctx).pop();
            },
            child:
                const Text('削除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
