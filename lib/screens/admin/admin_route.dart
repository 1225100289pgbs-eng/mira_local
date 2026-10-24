import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Ruta que aplica el tema administrativo (visualmente distinto al del cliente).
Route<T> adminRoute<T>(Widget page) => MaterialPageRoute<T>(
      builder: (_) => Theme(data: AppTheme.admin, child: page),
    );
