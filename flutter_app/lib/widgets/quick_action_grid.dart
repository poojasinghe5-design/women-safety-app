import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.location_on_rounded, 'label': 'Share\nLocation', 'color': 0xFF4CAF50, 'route': '/map'},
      {'icon': Icons.phone_in_talk_rounded, 'label': 'Fake\nCall', 'color': 0xFF7C4DFF, 'route': '/fake-call'},
      {'icon': Icons.mic_rounded, 'label': 'Record\nAudio', 'color': 0xFFFF5722, 'route': '/sos'},
      {'icon': Icons.people_rounded, 'label': 'Contacts', 'color': 0xFF2196F3, 'route': '/contacts'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Safety\nReport', 'color': 0xFFFF9800, 'route': '/report'},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': 0xFF888899, 'route': '/settings'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12,
        mainAxisSpacing: 12, childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        final color = Color(a['color'] as int);
        return GestureDetector(
          onTap: () => context.push(a['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(a['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(a['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: Colors.white, height: 1.2)),
              ],
            ),
          ),
        );
      },
    );
  }
}
