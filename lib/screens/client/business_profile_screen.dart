import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/status_badge.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key, required this.businessId});

  final String businessId;

  void _openPhoto(BuildContext context, String label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhotoBox(label: label, aspectRatio: 1, large: true),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Cerrar', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rate(BuildContext context, AppState state, Business b) async {
    if (state.currentOwner == null) {
      final login = await confirmDialog(
        context,
        title: 'Inicia sesión para calificar',
        message: 'Solo las personas con cuenta pueden calificar emprendimientos.',
        confirmLabel: 'Ir a iniciar sesión',
      );
      if (login && context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      return;
    }
    if (state.currentOwner?.email == b.ownerEmail) {
      showMessage(context, 'No puedes calificar tu propio emprendimiento',
          error: true);
      return;
    }
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RatingSheet(business: b),
    );
    if (sent == true && context.mounted) {
      showMessage(context, '¡Gracias por tu calificación!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.businessById(businessId);

    if (b == null || !b.visibleToClients) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState('Este emprendimiento no está disponible por ahora.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Emprendimiento')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          PhotoBox(label: b.cover, aspectRatio: 16 / 10),
          const SizedBox(height: 16),
          Text(b.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${state.categoryName(b.categoryId)} · ${b.zone}',
              style: const TextStyle(color: AppColors.gris)),
          const SizedBox(height: 8),
          RatingStars(value: b.average, count: b.ratingCount, size: 18),
          const SizedBox(height: 10),
          StatusBadge.availability(b.available),
          const SizedBox(height: 16),
          Text(b.description, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SectionTitle('Fotografías'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in b.photos)
                GestureDetector(
                  onTap: () => _openPhoto(context, p),
                  child: PhotoBox(label: p, width: 100, height: 100),
                ),
            ],
          ),
          const SectionTitle('Productos y precios'),
          if (b.products.isEmpty)
            const Text('Este negocio aún no registra productos.',
                style: TextStyle(color: AppColors.gris))
          else
            AppCard(
              child: Column(
                children: [
                  for (final p in b.products)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          PhotoBox(label: p.photo, width: 48, height: 48, radius: 8),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.name,
                              style: TextStyle(
                                color: p.available ? AppColors.tinta : AppColors.gris,
                              ),
                            ),
                          ),
                          if (!p.available)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: StatusBadge(
                                  text: 'Agotado', color: AppColors.gris),
                            ),
                          Text(formatPrice(p.price),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SectionTitle('Horario'),
          Text(b.scheduleText, style: const TextStyle(fontSize: 15)),
          const SectionTitle('Zona general'),
          Text(b.zone, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Por privacidad no mostramos la dirección exacta.',
              style: TextStyle(color: AppColors.gris, fontSize: 13)),
          const SectionTitle('Contacto'),
          Text('WhatsApp: ${b.whatsapp}', style: const TextStyle(fontSize: 15)),
          const SectionTitle('Calificaciones'),
          AppCard(child: RatingSummary(business: b)),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Calificar este emprendimiento',
            onPressed: () => _rate(context, state, b),
          ),
        ],
      ),
    );
  }
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.business});

  final Business business;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  final _comment = TextEditingController();
  int _stars = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    if (_stars == 0) {
      showMessage(context, 'Selecciona de una a cinco estrellas', error: true);
      return;
    }
    context.read<AppState>().addRating(widget.business, _stars, _comment.text);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calificar a ${widget.business.name}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          RatingInput(value: _stars, onChanged: (v) => setState(() => _stars = v)),
          const SizedBox(height: 12),
          AppTextField(
            controller: _comment,
            label: 'Comentario (opcional)',
            maxLines: 3,
          ),
          PrimaryButton(label: 'Enviar calificación', onPressed: _send),
        ],
      ),
    );
  }
}