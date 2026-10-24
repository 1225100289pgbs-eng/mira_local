import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'schedule_editor.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Set<int> _days;
  late int _open;
  late int _close;

  @override
  void initState() {
    super.initState();
    final b = context.read<AppState>().ownerBusiness;
    _days = Set<int>.of(b?.days ?? {});
    _open = b?.openMinutes ?? 9 * 60;
    _close = b?.closeMinutes ?? 18 * 60;
  }

  void _save(AppState state) {
    final b = state.ownerBusiness;
    if (b == null) return;
    if (_days.isEmpty) {
      showMessage(context, 'Selecciona al menos un día', error: true);
      return;
    }
    if (_close <= _open) {
      showMessage(context, 'La hora de cierre debe ser posterior a la apertura',
          error: true);
      return;
    }
    state.updateSchedule(b, _days, _open, _close);
    showMessage(context, 'Horario guardado');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.ownerBusiness;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Horarios')),
        body: const EmptyState('Primero registra tu emprendimiento.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Horarios y disponibilidad')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado actual',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        b.available
                            ? 'Tu emprendimiento aparece como disponible'
                            : 'Tu emprendimiento aparece como no disponible',
                        style: const TextStyle(color: AppColors.gris, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: b.available,
                  onChanged: (v) => state.setAvailability(b, v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ScheduleEditor(
            days: _days,
            openMinutes: _open,
            closeMinutes: _close,
            onDaysChanged: (v) => setState(() => _days = v),
            onOpenChanged: (v) => setState(() => _open = v),
            onCloseChanged: (v) => setState(() => _close = v),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Guardar cambios', onPressed: () => _save(state)),
        ],
      ),
    );
  }
}
