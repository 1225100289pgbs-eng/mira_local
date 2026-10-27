import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class MiraLocalApp extends StatelessWidget {
  const MiraLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mira Local',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.client,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
