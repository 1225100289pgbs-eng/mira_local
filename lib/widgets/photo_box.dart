import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Fotografía simulada: bloque de color cálido con la descripción.
/// Para usar fotos reales, sustituye el Container por Image.asset / Image.network.
class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    this.label,
    this.width,
    this.height,
    this.aspectRatio,
    this.radius = 14,
    this.large = false,
  });

  final String? label;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final double radius;
  final bool large;

  static const _tones = [
    Color(0xFFF3D9C9),
    Color(0xFFEBD8B5),
    Color(0xFFD9E3D0),
    Color(0xFFE6D2C3),
    Color(0xFFDCD3E3),
    Color(0xFFF0CFC4),
  ];

  @override
  Widget build(BuildContext context) {
    final text = label;
    final color = text == null
        ? AppColors.borde
        : _tones[text.codeUnits.fold<int>(0, (a, b) => a + b) % _tones.length];
    final box = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text ?? 'Sin fotografía',
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          fontSize: large ? 18 : 12,
          color: AppColors.tinta.withValues(alpha: 0.6),
        ),
      ),
    );
    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: box);
    }
    return SizedBox(width: width, height: height, child: box);
  }
}
