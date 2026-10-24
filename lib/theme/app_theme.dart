import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const terracota = Color(0xFFD95F3B);
  static const crema = Color(0xFFFAFAF7);
  static const tinta = Color(0xFF1A1A16);
  static const gris = Color(0xFF8A8578);
  static const borde = Color(0xFFE8E0D6);
  static const exito = Color(0xFF2D6A4F);
  static const error = Color(0xFFB3261E);
  static const estrella = Color(0xFFE0A100);
  static const pendiente = Color(0xFFB7791F);
  static const suspendido = Color(0xFF6D4C93);
  // Interfaz administrativa (visualmente distinta)
  static const adminPrimario = Color(0xFF2F3E46);
  static const adminFondo = Color(0xFFEEF1F3);
}

class AppTheme {
  static final ThemeData client = _build(
    primary: AppColors.terracota,
    background: AppColors.crema,
    appBarColor: AppColors.crema,
    appBarForeground: AppColors.tinta,
    serif: true,
  );

  static final ThemeData admin = _build(
    primary: AppColors.adminPrimario,
    background: AppColors.adminFondo,
    appBarColor: AppColors.adminPrimario,
    appBarForeground: Colors.white,
    serif: false,
  );

  static TextStyle titulo(double size, {Color? color}) => GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.tinta,
      );

  static ThemeData _build({
    required Color primary,
    required Color background,
    required Color appBarColor,
    required Color appBarForeground,
    required bool serif,
  }) {
    final scheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.tinta,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borde,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: AppColors.borde,
    );

    TextStyle heading(double size, Color color) => serif
        ? GoogleFonts.fraunces(fontSize: size, fontWeight: FontWeight.w600, color: color)
        : GoogleFonts.outfit(fontSize: size, fontWeight: FontWeight.w700, color: color);

    final base = GoogleFonts.outfitTextTheme()
        .apply(bodyColor: AppColors.tinta, displayColor: AppColors.tinta);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: base.copyWith(
        headlineLarge: heading(30, AppColors.tinta),
        headlineMedium: heading(26, AppColors.tinta),
        headlineSmall: heading(22, AppColors.tinta),
        titleLarge: heading(20, AppColors.tinta),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: heading(20, appBarForeground),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 50),
          shape: shape,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(88, 50),
          shape: shape,
          side: BorderSide(color: primary.withValues(alpha: 0.5)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(AppColors.borde),
        enabledBorder: border(AppColors.borde),
        focusedBorder: border(primary),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error),
        hintStyle: const TextStyle(color: AppColors.gris),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primary.withValues(alpha: 0.14),
        side: const BorderSide(color: AppColors.borde),
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.tinta),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
      ),
    );
  }
}
