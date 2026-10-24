import 'package:flutter/material.dart';

import '../../utils/format.dart';

/// Selector de días y de hora de apertura y cierre.
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    super.key,
    required this.days,
    required this.openMinutes,
    required this.closeMinutes,
    required this.onDaysChanged,
    required this.onOpenChanged,
    required this.onCloseChanged,
  });

  final Set<int> days;
  final int openMinutes;
  final int closeMinutes;
  final ValueChanged<Set<int>> onDaysChanged;
  final ValueChanged<int> onOpenChanged;
  final ValueChanged<int> onCloseChanged;

  Future<void> _pick(
      BuildContext context, int current, ValueChanged<int> onChanged) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (t != null) onChanged(t.hour * 60 + t.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Días de atención',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 1; i <= 7; i++)
              FilterChip(
                label: Text(dayNames[i - 1]),
                selected: days.contains(i),
                showCheckmark: false,
                onSelected: (v) {
                  final next = {...days};
                  v ? next.add(i) : next.remove(i);
                  onDaysChanged(next);
                },
              ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('Horario de atención',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, openMinutes, onOpenChanged),
                child: Text('Abre ${formatMinutes(openMinutes)}',
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, closeMinutes, onCloseChanged),
                child: Text('Cierra ${formatMinutes(closeMinutes)}',
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
