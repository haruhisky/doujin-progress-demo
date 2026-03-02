import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../providers/project_provider.dart';

/// プロジェクト情報編集カード
class ProjectInfoCard extends ConsumerStatefulWidget {
  const ProjectInfoCard({super.key});

  @override
  ConsumerState<ProjectInfoCard> createState() => _ProjectInfoCardState();
}

class _ProjectInfoCardState extends ConsumerState<ProjectInfoCard> {
  late TextEditingController _nameCtrl;
  late TextEditingController _pagesCtrl;
  DateTime? _startDate;
  DateTime? _deadline;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _pagesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  void _startEditing() {
    final project = ref.read(activeProjectProvider);
    if (project == null) return;
    _nameCtrl.text = project.name;
    _pagesCtrl.text = project.totalPages.toString();
    _startDate = parseDate(project.startDate);
    _deadline = parseDate(project.deadline);
    setState(() => _editing = true);
  }

  void _save() {
    final project = ref.read(activeProjectProvider);
    if (project == null) return;
    final name = _nameCtrl.text.trim();
    final pages = int.tryParse(_pagesCtrl.text) ?? project.totalPages;
    if (name.isNotEmpty) {
      project.name = name;
      project.totalPages = pages;
      if (_startDate != null) {
        project.startDate = formatDate(_startDate!);
      }
      if (_deadline != null) {
        project.deadline = formatDate(_deadline!);
      }
      ref.read(projectsProvider.notifier).update(project);
    }
    setState(() => _editing = false);
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart ? _startDate : _deadline;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

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
              Icon(Icons.info_outline, size: 18, color: AppTheme.secondary),
              const SizedBox(width: 6),
              Text(
                'プロジェクト情報',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _editing ? _save : _startEditing,
                child: Text(
                  _editing ? '保存' : '編集',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_editing) ...[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'プロジェクト名'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pagesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '総ページ数'),
            ),
            const SizedBox(height: 12),
            _DatePickerRow(
              label: '開始日',
              date: _startDate,
              onTap: () => _pickDate(context, true),
            ),
            const SizedBox(height: 8),
            _DatePickerRow(
              label: '締切日',
              date: _deadline,
              onTap: () => _pickDate(context, false),
            ),
          ] else ...[
            _InfoRow('名前', project.name),
            _InfoRow('ページ数', '${project.totalPages}P'),
            _InfoRow('開始日', project.startDate),
            _InfoRow('締切', project.deadline),
          ],
        ],
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(label,
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
            ),
            Icon(Icons.calendar_today, size: 14, color: AppTheme.textLight),
            const SizedBox(width: 8),
            Text(
              date != null ? formatDateJp(date!) : '未設定',
              style: TextStyle(fontSize: 13, color: AppTheme.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
