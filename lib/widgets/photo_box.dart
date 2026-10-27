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

  // Lado menor conocido (infinito si el tamaño lo da el aspectRatio).
  var side = double.infinity;
  if (width != null && width! < side) side = width!;
  if (height != null && height! < side) side = height!;
  final tiny = side < 70; // miniaturas: solo la etiqueta "FOTO"
  final sized = side.isFinite;

  final content = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'FOTO',
        style: GoogleFonts.outfit(
          fontSize: large ? 14 : (tiny ? 9 : 10),
          fontWeight: FontWeight.w700,
          letterSpacing: tiny ? 1 : 1.5,
          color: AppColors.tinta.withValues(alpha: 0.4),
        ),
      ),
      if (!tiny)
        Text(
          text ?? 'Sin fotografía',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: large ? 18 : 12,
            color: AppColors.tinta.withValues(alpha: 0.6),
          ),
        ),
    ],
  );

  final box = Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
    alignment: Alignment.center,
    padding: EdgeInsets.all(tiny ? 2 : 8),
    // En cajas de tamaño fijo, FittedBox reduce el contenido para que nunca se desborde.
    child: sized
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: side - (tiny ? 4 : 16),
              child: content,
            ),
          )
        : content,
  );

  if (aspectRatio != null) {
    return AspectRatio(aspectRatio: aspectRatio!, child: box);
  }
  return SizedBox(width: width, height: height, child: box);
}
}
