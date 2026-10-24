import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/rating_stars.dart';
import 'admin_route.dart';

/// Consulta de solo lectura: el administrador no puede modificar calificaciones.
class AdminRatingsScreen extends StatelessWidget {
  const AdminRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.businesses;
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: list.isEmpty
          ? const EmptyState('No hay emprendimientos registrados.')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final b in list)
                  AppCard(
                    onTap: () => Navigator.push(
                      context,
                      adminRoute(AdminRatingDetailScreen(businessId: b.id)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        RatingStars(value: b.average, count: b.ratingCount),
                        const SizedBox(height: 8),
                        RatingDistribution(distribution: b.distribution),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class AdminRatingDetailScreen extends StatelessWidget {
  const AdminRatingDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context) {
    final b = context.watch<AppState>().businessById(businessId);
    if (b == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState('El emprendimiento ya no existe.'),
      );
    }
    final ratings = b.ratings.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: Text(b.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(child: RatingSummary(business: b)),
          const Text('Solo lectura: las calificaciones no se pueden modificar.',
              style: TextStyle(color: AppColors.gris, fontSize: 13)),
          const SectionTitle('Comentarios'),
          if (ratings.isEmpty)
            const Text('Aún no hay calificaciones.',
                style: TextStyle(color: AppColors.gris)),
          for (final r in ratings)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('★' * r.stars + '☆' * (5 - r.stars),
                          style: const TextStyle(color: AppColors.estrella)),
                      Text(formatDate(r.date),
                          style: const TextStyle(
                              color: AppColors.gris, fontSize: 12)),
                    ],
                  ),
                  if (r.comment.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.comment),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
