import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(title: Text('Live Map', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: const Center(child: Text('Map coming soon', style: TextStyle(color: Colors.white))),
    );
  }
}
