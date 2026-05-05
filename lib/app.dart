import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/end_tour_screen.dart';

class MuseumGuideApp extends StatelessWidget {
  const MuseumGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppConstants.routeHome,
      routes: {
        AppConstants.routeHome: (_) => const HomeScreen(),
        AppConstants.routeHistory: (_) => const HistoryScreen(),
        AppConstants.routeSettings: (_) => const SettingsScreen(),
        AppConstants.routeEndTour: (_) => const EndTourScreen(),
      },
    );
  }
}
