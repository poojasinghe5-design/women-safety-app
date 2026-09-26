import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyStatusCard extends StatelessWidget {
  const SafetyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF4CAF50).withOpacity(0.12),
          const Color(0xFF1A2E1A),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Color(0xFF4CAF50), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are in a Safe Zone', style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text('AI safety score: 87/100 · Low risk area', style: GoogleFonts.poppins(
                  fontSize: 11, color: const Color(0xFF4CAF50))),
              ],
            ),
          ),
          Column(children: [
            Text('87', style: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF4CAF50))),
            Text('SAFE', style: GoogleFonts.poppins(
              fontSize: 8, color: const Color(0xFF4CAF50), letterSpacing: 1.5)),
          ]),
        ],
      ),
    );
  }
}
