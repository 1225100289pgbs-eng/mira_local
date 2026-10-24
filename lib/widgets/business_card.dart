import 'package:flutter/material.dart';

import '../models/business.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'photo_box.dart';
import 'rating_stars.dart';
import 'status_badge.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.business,
    required this.categoryName,
    required this.onTap,
    this.showStatus = false,
    this.pendingRequest = false,
  });

  final Business business;
  final String categoryName;
  final VoidCallback onTap;

  /// En vistas administrativas muestra estado y disponibilidad.
  final bool showStatus;
  final bool pendingRequest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          PhotoBox(label: business.cover, width: 88, height: 88),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$categoryName · ${business.zone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.gris, fontSize: 13),
                ),
                const SizedBox(height: 6),
                RatingStars(value: business.average, count: business.ratingCount),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (showStatus) StatusBadge.status(business.status),
                    StatusBadge.availability(business.available),
                    if (pendingRequest)
                      const StatusBadge(
                          text: 'Solicitud pendiente', color: AppColors.terracota),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
