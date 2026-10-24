import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/status_badge.dart';
import 'gallery_screen.dart';
import 'rating_screen.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key, required this.businessId});

  final String businessId;

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
          SectionTitle(
            'Fotografías',
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GalleryScreen(businessId: b.id)),
              ),
              child: Text('Ver galería (${b.photos.length})'),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in b.photos.take(4))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PhotoBox(label: p, width: 80, height: 80),
                  ),
              ],
            ),
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
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Calificar este emprendimiento',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RatingScreen(businessId: b.id)),
            ),
          ),
        ],
      ),
    );
  }
}
