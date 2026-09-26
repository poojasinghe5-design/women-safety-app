import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF3B7A), Color(0xFFE91E8C)]),
                boxShadow: [BoxShadow(
                  color: const Color(0xFFE91E8C).withOpacity(0.5),
                  blurRadius: 30)],
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),
            Text('SafeHer', style: GoogleFonts.poppins(
              fontSize: 40, fontWeight: FontWeight.w800,
              color: const Color(0xFFE91E8C), letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Your safety. Our priority.', style: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF666677))),
          ],
        ),
      ),
    );
  }
}
