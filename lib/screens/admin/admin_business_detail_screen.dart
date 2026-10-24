import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/status_badge.dart';

class AdminBusinessDetailScreen extends StatelessWidget {
  const AdminBusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  Future<void> _approve(BuildContext context, AppState state, Business b) async {
    final ok = await confirmDialog(
      context,
      title: '¿Aprobar "${b.name}"?',
      message: 'Será visible para los clientes mientras esté disponible.',
      confirmLabel: 'Aprobar',
    );
    if (!ok || !context.mounted) return;
    state.approve(b);
    showMessage(context, 'Emprendimiento aprobado');
  }

  Future<void> _reactivate(BuildContext context, AppState state, Business b) async {
    final ok = await confirmDialog(
      context,
      title: '¿Reactivar "${b.name}"?',
      message:
          'Volverá a estar activo y disponible, y se resolverá la notificación y la solicitud.',
      confirmLabel: 'Reactivar',
    );
    if (!ok || !context.mounted) return;
    state.reactivate(b);
    showMessage(context, 'Emprendimiento reactivado');
  }

  Future<void> _sanction(
      BuildContext context, AppState state, Business b, bool reject) async {
    final reason = await askReasonAndConfirm(
      context,
      action: reject ? 'Rechazar' : 'Suspender',
      businessName: b.name,
    );
    if (reason == null || !context.mounted) return;
    if (reject) {
      state.reject(b, reason);
    } else {
      state.suspend(b, reason);
    }
    showMessage(context, reject ? 'Emprendimiento rechazado' : 'Emprendimiento suspendido');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.businessById(businessId);
    if (b == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState('El emprendimiento ya no existe.'),
      );
    }
    final request = state.requestFor(b.id);
    final notice = state.noticeFor(b.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(b.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${state.categoryName(b.categoryId)} · ${b.zone}',
              style: const TextStyle(color: AppColors.gris)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge.status(b.status),
              StatusBadge.availability(b.available),
              if (request != null)
                const StatusBadge(
                    text: 'Solicitud pendiente', color: AppColors.terracota),
            ],
          ),
          const SizedBox(height: 14),
          Text(b.description, style: const TextStyle(height: 1.4)),
          if (notice != null) ...[
            const SectionTitle('Última notificación enviada'),
            AppCard(
              borderColor: statusColor(notice.status),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado: ${notice.status.label}'),
                  Text('Fecha: ${formatDate(notice.date)}'),
                  Text('Motivo: ${notice.reason}'),
                ],
              ),
            ),
          ],
          if (request != null) ...[
            const SectionTitle('Solicitud de reactivación'),
            AppCard(
              borderColor: AppColors.terracota,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha: ${formatDate(request.date)}'),
                  const SizedBox(height: 4),
                  Text('Mensaje del emprendedor:',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(request.message),
                ],
              ),
            ),
          ],
          const SectionTitle('Emprendedor'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.ownerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(b.ownerEmail),
                Text('WhatsApp: ${b.whatsapp}'),
              ],
            ),
          ),
          const SectionTitle('Horario'),
          Text(b.scheduleText),
          const SectionTitle('Fotografías'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in b.photos) PhotoBox(label: p, width: 90, height: 90),
            ],
          ),
          const SectionTitle('Productos y precios'),
          if (b.products.isEmpty)
            const Text('Sin productos registrados.',
                style: TextStyle(color: AppColors.gris))
          else
            AppCard(
              child: Column(
                children: [
                  for (final p in b.products)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  '${p.name}${p.available ? '' : ' (agotado)'}')),
                          Text(formatPrice(p.price),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SectionTitle('Calificaciones'),
          AppCard(child: RatingSummary(business: b)),
          const SizedBox(height: 12),
          if (b.status == BusinessStatus.pending) ...[
            PrimaryButton(label: 'Aprobar', onPressed: () => _approve(context, state, b)),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Rechazar',
              outlined: true,
              destructive: true,
              onPressed: () => _sanction(context, state, b, true),
            ),
          ],
          if (b.status == BusinessStatus.active)
            PrimaryButton(
              label: 'Suspender',
              outlined: true,
              destructive: true,
              onPressed: () => _sanction(context, state, b, false),
            ),
          if (b.status == BusinessStatus.rejected ||
              b.status == BusinessStatus.suspended)
            PrimaryButton(
              label: 'Reactivar emprendimiento',
              onPressed: () => _reactivate(context, state, b),
            ),
        ],
      ),
    );
  }
}
