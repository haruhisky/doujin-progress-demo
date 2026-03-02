import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/models/process_def.dart';
import '../../../providers/project_provider.dart';

/// 工程編集カード（色・アイコン・名前・並替・追加・削除）
class ProcessEditor extends ConsumerStatefulWidget {
  const ProcessEditor({super.key});

  @override
  ConsumerState<ProcessEditor> createState() => _ProcessEditorState();
}

class _ProcessEditorState extends ConsumerState<ProcessEditor> {
  @override
  Widget build(BuildContext context) {
    final project = ref.watch(activeProjectProvider);
    if (project == null) return const SizedBox.shrink();

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 18, color: AppTheme.tertiary),
              const SizedBox(width: 6),
              Text(
                '工程設定',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _addProcess(project.id, project.processes),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.tertiary),
                      const SizedBox(width: 2),
                      Text(
                        '追加',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.tertiary,
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

          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: project.processes.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final procs = List<ProcessDef>.from(project.processes);
              final item = procs.removeAt(oldIndex);
              procs.insert(newIndex, item);
              ref
                  .read(projectsProvider.notifier)
                  .updateProcesses(project.id, procs);
            },
            itemBuilder: (context, index) {
              final proc = project.processes[index];
              final color = colorFromHex(proc.color);

              return ListTile(
                key: ValueKey(proc.id),
                contentPadding: EdgeInsets.zero,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(proc.icon, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                title: Text(
                  proc.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _editProcess(context, project.id,
                          project.processes, index),
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: AppTheme.textLight),
                    ),
                    if (project.processes.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: GestureDetector(
                          onTap: () {
                            final procs =
                                List<ProcessDef>.from(project.processes);
                            procs.removeAt(index);
                            ref
                                .read(projectsProvider.notifier)
                                .updateProcesses(project.id, procs);
                          },
                          child: Icon(Icons.close,
                              size: 16, color: AppTheme.textLight),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.drag_handle,
                        size: 18, color: AppTheme.textLight),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addProcess(String projectId, List<ProcessDef> current) {
    final colorIndex = current.length % ProcessColors.extraHexes.length;
    final newProc = ProcessDef(
      id: const Uuid().v4(),
      label: '新しい工程',
      icon: '🎨',
      color: ProcessColors.extraHexes[colorIndex],
    );
    final procs = [...current, newProc];
    ref.read(projectsProvider.notifier).updateProcesses(projectId, procs);
  }

  void _editProcess(BuildContext context, String projectId,
      List<ProcessDef> current, int index) {
    final proc = current[index];
    final nameCtrl = TextEditingController(text: proc.label);
    String selectedIcon = proc.icon;
    String selectedColor = proc.color;

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
              Text('工程を編集',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: '工程名'),
              ),
              const SizedBox(height: 12),
              Text('アイコン',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textLight)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProcessIcons.all.map((icon) {
                  final isSelected = icon == selectedIcon;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedIcon = icon),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppTheme.primary)
                            : null,
                      ),
                      child: Center(
                          child: Text(icon,
                              style: const TextStyle(fontSize: 18))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text('カラー',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textLight)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  '#D4A0B9',
                  '#D4BC8A',
                  '#8EB5C9',
                  '#8EBB9E',
                  ...ProcessColors.extraHexes,
                ].map((hex) {
                  final c = colorFromHex(hex);
                  final isSelected = hex == selectedColor;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.textColor, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final label = nameCtrl.text.trim();
                    if (label.isEmpty) return;
                    final procs = List<ProcessDef>.from(current);
                    procs[index] = proc.copyWith(
                      label: label,
                      icon: selectedIcon,
                      color: selectedColor,
                    );
                    ref
                        .read(projectsProvider.notifier)
                        .updateProcesses(projectId, procs);
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
}
