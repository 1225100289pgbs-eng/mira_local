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
import 'business_form_screen.dart';
import 'manage_photos_screen.dart';
import 'manage_products_screen.dart';
import 'schedule_screen.dart';

class OwnerPanelScreen extends StatelessWidget {
  const OwnerPanelScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: '¿Cerrar sesión?',
      message: 'Volverás a la pantalla de inicio de Mira Local.',
      confirmLabel: 'Cerrar sesión',
    );
    if (!ok || !context.mounted) return;
    context.read<AppState>().logoutOwner();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _requestReactivation(
      BuildContext context, AppState state, Business b) async {
    final message = await promptDialog(
      context,
      title: 'Solicitar reactivación',
      label: '¿Qué corregiste?',
      description: 'Explica al administrador los cambios que realizaste.',
      maxLines: 4,
      confirmLabel: 'Enviar solicitud',
    );
    if (message == null || !context.mounted) return;
    final ok = state.requestReactivation(b, message);
    showMessage(
      context,
      ok ? 'Solicitud enviada al administrador' : 'Ya tienes una solicitud pendiente',
      error: !ok,
    );
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.ownerBusiness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi negocio'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
      body: b == null
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 40),
                const EmptyState('Aún no registras tu emprendimiento.'),
                PrimaryButton(
                  label: 'Registrar mi emprendimiento',
                  onPressed: () => _open(context, const BusinessFormScreen()),
                ),
              ],
            )
          : _content(context, state, b),
    );
  }

  Widget _content(BuildContext context, AppState state, Business b) {
    final notice = state.noticeFor(b.id);
    final hasRequest = state.hasPendingRequest(b.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        PhotoBox(label: b.cover, aspectRatio: 16 / 8),
        const SizedBox(height: 14),
        Text(b.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text('${state.categoryName(b.categoryId)} · ${b.zone}',
            style: const TextStyle(color: AppColors.gris)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Estado: ', style: TextStyle(fontWeight: FontWeight.w500)),
            StatusBadge.status(b.status),
          ],
        ),
        const SizedBox(height: 14),
        if (b.status == BusinessStatus.pending)
          const AppCard(
            borderColor: AppColors.pendiente,
            child: Text(
              'Tu emprendimiento está pendiente de aprobación. '
              'Aún no es visible para los clientes.',
            ),
          ),
        if (notice != null)
          AppCard(
            borderColor: statusColor(notice.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu emprendimiento fue ${notice.status == BusinessStatus.rejected ? 'rechazado' : 'suspendido'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('Estado: ${notice.status.label}'),
                const SizedBox(height: 4),
                Text('Motivo: ${notice.reason}'),
                const SizedBox(height: 4),
                Text('Fecha: ${formatDate(notice.date)}'),
                const SizedBox(height: 8),
                const Text(
                  'Tu negocio no es visible para los clientes.',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (hasRequest)
                  const StatusBadge(
                      text: 'Solicitud enviada, en revisión',
                      color: AppColors.terracota)
                else
                  PrimaryButton(
                    label: 'Solicitar reactivación',
                    onPressed: () => _requestReactivation(context, state, b),
                  ),
              ],
            ),
          ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Disponible para clientes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Switch(
                    value: b.available,
                    onChanged: (v) => state.setAvailability(b, v),
                  ),
                ],
              ),
              if (b.status != BusinessStatus.active)
                const Text(
                  'Los clientes solo verán tu negocio cuando esté activo y disponible.',
                  style: TextStyle(color: AppColors.gris, fontSize: 13),
                ),
            ],
          ),
        ),
        const SectionTitle('Tu calificación'),
        AppCard(child: RatingSummary(business: b)),
        const SectionTitle('Administrar emprendimiento'),
        _MenuTile(
          title: 'Productos',
          subtitle: '${b.products.length} registrados',
          onTap: () => _open(context, const ManageProductsScreen()),
        ),
        _MenuTile(
          title: 'Fotografías',
          subtitle: '${b.photos.length} en la galería',
          onTap: () => _open(context, const ManagePhotosScreen()),
        ),
        _MenuTile(
          title: 'Horarios y disponibilidad',
          subtitle: b.scheduleText,
          onTap: () => _open(context, const ScheduleScreen()),
        ),
        _MenuTile(
          title: 'Información general',
          subtitle: 'Nombre, descripción, zona y WhatsApp',
          onTap: () => _open(context, BusinessFormScreen(editing: b)),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.gris, fontSize: 13)),
              ],
            ),
          ),
          const Text('›', style: TextStyle(fontSize: 24, color: AppColors.gris)),
        ],
      ),
    );
  }
}
