import 'package:flutter/material.dart';

import '../models/business.dart';
import '../theme/app_theme.dart';

/// Estrellas de solo lectura (texto, sin iconos).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, this.count, this.size = 16});

  final double value;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const Text('Sin calificaciones',
          style: TextStyle(color: AppColors.gris, fontSize: 13));
    }
    final full = value.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('★' * full + '☆' * (5 - full),
            style: TextStyle(fontSize: size, color: AppColors.estrella)),
        const SizedBox(width: 6),
        Text(
          count == null
              ? value.toStringAsFixed(1)
              : '${value.toStringAsFixed(1)} ($count)',
          style: const TextStyle(color: AppColors.gris, fontSize: 13),
        ),
      ],
    );
  }
}

/// Selector de una a cinco estrellas.
class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: true,
            label: '$i estrellas',
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  i <= value ? '★' : '☆',
                  style: const TextStyle(fontSize: 44, color: AppColors.estrella),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Distribución de una a cinco estrellas con barras.
class RatingDistribution extends StatelessWidget {
  const RatingDistribution({super.key, required this.distribution});

  final List<int> distribution;

  @override
  Widget build(BuildContext context) {
    final total = distribution.fold<int>(0, (a, b) => a + b);
    return Column(
      children: [
        for (var s = 5; s >= 1; s--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text('$s ★',
                      style: const TextStyle(fontSize: 13, color: AppColors.gris)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : distribution[s - 1] / total,
                      minHeight: 6,
                      backgroundColor: AppColors.borde,
                      color: AppColors.estrella,
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  child: Text('${distribution[s - 1]}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, color: AppColors.gris)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Promedio grande + cantidad + distribución.
class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final b = business;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              b.ratingCount == 0 ? '—' : b.average.toStringAsFixed(1),
              style: AppTheme.titulo(36),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingStars(value: b.average, count: null, size: 18),
                Text('${b.ratingCount} calificaciones',
                    style: const TextStyle(color: AppColors.gris, fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        RatingDistribution(distribution: b.distribution),
      ],
    );
  }
}
