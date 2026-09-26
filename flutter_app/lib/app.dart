import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/map_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/fake_call_screen.dart';
import 'screens/safety_report_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

class WomenSafetyApp extends ConsumerWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (BuildContext ctx, GoRouterState st) => HomeScreen(),
        ),
        GoRoute(
          path: '/splash',
          builder: (BuildContext ctx, GoRouterState st) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext ctx, GoRouterState st) => LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext ctx, GoRouterState st) => RegisterScreen(),
        ),
        GoRoute(
          path: '/sos',
          builder: (BuildContext ctx, GoRouterState st) => SosScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (BuildContext ctx, GoRouterState st) => MapScreen(),
        ),
        GoRoute(
          path: '/contacts',
          builder: (BuildContext ctx, GoRouterState st) => ContactsScreen(),
        ),
        GoRoute(
          path: '/fake-call',
          builder: (BuildContext ctx, GoRouterState st) => FakeCallScreen(),
        ),
        GoRoute(
          path: '/report',
          builder: (BuildContext ctx, GoRouterState st) => SafetyReportScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext ctx, GoRouterState st) => SettingsScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'SafeHer',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E8C),
        brightness: Brightness.dark,
        primary: const Color(0xFFE91E8C),
        secondary: const Color(0xFFFF6B9D),
        surface: const Color(0xFF0D0D1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0A14),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E8C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF888899)),
        hintStyle: const TextStyle(color: Color(0xFF555566)),
      ),
    );
  }
}