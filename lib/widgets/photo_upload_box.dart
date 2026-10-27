import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'photo_box.dart';

/// Espacio para "subir" una fotografía (simulado, sin cámara ni galería).
class PhotoUploadBox extends StatelessWidget {
  const PhotoUploadBox({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 110,
  });

  final String? label;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = label != null && label!.isNotEmpty;
    if (hasPhoto) {
      return Column(
        children: [
          PhotoBox(label: label, width: double.infinity, height: height),
          TextButton(onPressed: onTap, child: const Text('Cambiar foto')),
        ],
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde, width: 1.5),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+',
                style: TextStyle(fontSize: 28, color: AppColors.terracota)),
            Text('Subir foto',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Toca para seleccionar (simulado)',
                style: TextStyle(fontSize: 12, color: AppColors.gris)),
          ],
        ),
      ),
    );
  }
}