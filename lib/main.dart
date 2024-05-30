// lib/main.dart
import 'package:flutter/material.dart';
import 'package:voxiloud/pages/auth/auth_page.dart';
import 'package:voxiloud/pages/dashboard/dashboard_page.dart';
import 'package:voxiloud/pages/dashboard/home/home_page.dart';
import 'package:voxiloud/pages/dashboard/tools/docs_page.dart';
import 'package:voxiloud/pages/dashboard/tools/translate_page.dart';
import 'package:voxiloud/pages/dashboard/tools/tts_page.dart';
import 'package:voxiloud/pages/loading_page.dart';
import 'package:provider/provider.dart';
import 'package:voxiloud/themes/theme_provider.dart';
import 'package:voxiloud/themes/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (!themeProvider.isInitialized) {
          // Show a loading indicator until the theme is loaded
          return const Center(child: CircularProgressIndicator());
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          title: 'Voxiloud',
          theme: ThemeClass.lightTheme,
          darkTheme: ThemeClass.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoadingPage(),
            '/auth': (context) => const AuthPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/tts': (context) => const TtsPage(),
            '/docs': (context) => const DocsPage(),
            '/translate': (context) => const TranslatePage(),
          },
        );
      },
    );
  }
}
