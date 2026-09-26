import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NearbyAlertBanner extends StatelessWidget {
  const NearbyAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFFF9800), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Moderate risk reported 500m away at night',
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFFFCC80))),
          ),
          Text('View', style: GoogleFonts.poppins(
            fontSize: 11, color: const Color(0xFFFF9800), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
