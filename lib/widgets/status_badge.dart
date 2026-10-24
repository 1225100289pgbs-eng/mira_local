import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/business.dart';
import '../theme/app_theme.dart';

Color statusColor(BusinessStatus s) {
  switch (s) {
    case BusinessStatus.pending:
      return AppColors.pendiente;
    case BusinessStatus.active:
      return AppColors.exito;
    case BusinessStatus.rejected:
      return AppColors.error;
    case BusinessStatus.suspended:
      return AppColors.suspendido;
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.text, required this.color});

  factory StatusBadge.status(BusinessStatus s) =>
      StatusBadge(text: s.label, color: statusColor(s));

  factory StatusBadge.availability(bool available) => StatusBadge(
        text: available ? 'Disponible' : 'No disponible',
        color: available ? AppColors.exito : AppColors.gris,
      );

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
