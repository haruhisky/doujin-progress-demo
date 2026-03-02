import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';

/// イベントタスク追加フォーム（ボトムシート）
class EventAddForm extends StatefulWidget {
  final DateTime date;
  final Function(String label, String date, String color) onSave;

  const EventAddForm({
    super.key,
    required this.date,
    required this.onSave,
  });

  @override
  State<EventAddForm> createState() => _EventAddFormState();
}

class _EventAddFormState extends State<EventAddForm> {
  final _controller = TextEditingController();
  String _selectedColor = kEventTaskDefaultColor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ハンドル
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

          Text(
            'イベントを追加',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDateJp(widget.date),
            style: TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'イベント名',
            ),
          ),
          const SizedBox(height: 12),

          // カラー選択
          Wrap(
            spacing: 8,
            children: [
              kEventTaskDefaultColor,
              '#D4A0B9',
              '#8EB5C9',
              '#8EBB9E',
              '#D4BC8A',
            ].map((hex) {
              final color = colorFromHex(hex);
              final selected = hex == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: AppTheme.textColor, width: 2)
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
                final label = _controller.text.trim();
                if (label.isEmpty) return;
                widget.onSave(label, formatDate(widget.date), _selectedColor);
                Navigator.of(context).pop();
              },
              child: const Text('追加'),
            ),
          ),
        ],
      ),
    );
  }
}
