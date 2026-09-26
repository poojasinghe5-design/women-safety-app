import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';
import '../services/audio_service.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});
  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _countdownController;
  bool _sosActive = false;
  bool _counting = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  String _status = 'Press & hold SOS to activate';

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _countdownController.dispose();
    _countdownTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startCountdown() {
    if (_sosActive) return;
    setState(() {
      _counting = true;
      _countdown = 3;
      _status = 'Activating SOS...';
    });
    _countdownController.forward(from: 0);
    HapticFeedback.heavyImpact();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      HapticFeedback.mediumImpact();
      if (_countdown <= 0) {
        t.cancel();
        _activateSOS();
      }
    });
  }

  void _cancelCountdown() {
    if (_sosActive) return;
    _countdownTimer?.cancel();
    _countdownController.reset();
    setState(() {
      _counting = false;
      _countdown = 3;
      _status = 'Press & hold SOS to activate';
    });
  }

  Future<void> _activateSOS() async {
    setState(() {
      _sosActive = true;
      _counting = false;
      _status = '🚨 SOS ACTIVE — Alerting contacts';
    });
    WakelockPlus.enable();
    HapticFeedback.vibrate();

    // Start all emergency services in parallel
    await Future.wait([
      ref.read(sosServiceProvider).sendSOSAlert(),
      ref.read(audioServiceProvider).startRecording(),
      ref.read(locationServiceProvider).startContinuousSharing(),
    ]);
  }

  void _deactivateSOS() {
    ref.read(sosServiceProvider).cancelSOS();
    ref.read(audioServiceProvider).stopRecording();
    ref.read(locationServiceProvider).stopContinuousSharing();
    WakelockPlus.disable();
    setState(() {
      _sosActive = false;
      _status = 'SOS deactivated';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sosActive ? const Color(0xFF1A000A) : const Color(0xFF0A0A14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildSOSCenter()),
            _buildStatusCards(),
            if (_sosActive) _buildCancelButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Emergency SOS',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSOSCenter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated rings
          Stack(
            alignment: Alignment.center,
            children: [
              if (_sosActive)
                ...List.generate(4, (i) {
                  return AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) {
                      final progress = (_ringController.value + (i / 4)) % 1.0;
                      return Transform.scale(
                        scale: 1.0 + (progress * 0.8),
                        child: Opacity(
                          opacity: (1.0 - progress).clamp(0.0, 1.0),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFFF1744), width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              // Main button
              GestureDetector(
                onLongPressStart: (_) => _startCountdown(),
                onLongPressEnd: (_) => _cancelCountdown(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _sosActive ? 180 : (_counting ? 160 : 170),
                  height: _sosActive ? 180 : (_counting ? 160 : 170),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _sosActive
                          ? [const Color(0xFFFF5252), const Color(0xFFFF1744), const Color(0xFFB71C1C)]
                          : [const Color(0xFFFF3B7A), const Color(0xFFE91E8C), const Color(0xFFAA0055)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_sosActive
                                ? const Color(0xFFFF1744)
                                : const Color(0xFFE91E8C))
                            .withOpacity(0.6),
                        blurRadius: _sosActive ? 50 : 30,
                        spreadRadius: _sosActive ? 10 : 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_counting)
                        Text('$_countdown',
                            style: GoogleFonts.poppins(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white))
                      else ...[
                        Icon(
                          _sosActive
                              ? Icons.warning_rounded
                              : Icons.shield_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 8),
                        Text(_sosActive ? 'SOS\nACTIVE' : 'SOS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: _sosActive ? 24 : 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1)),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(_status,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _sosActive
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF888899))),
          if (!_sosActive) ...[
            const SizedBox(height: 8),
            Text('Hold for 3 seconds to send alert',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF444455))),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statusCard(
            Icons.location_on_rounded,
            'Location',
            _sosActive ? 'Sharing' : 'Ready',
            _sosActive ? const Color(0xFF4CAF50) : const Color(0xFF555566),
          ),
          const SizedBox(width: 12),
          _statusCard(
            Icons.mic_rounded,
            'Recording',
            _sosActive ? 'Active' : 'Standby',
            _sosActive ? const Color(0xFFFF5252) : const Color(0xFF555566),
          ),
          const SizedBox(width: 12),
          _statusCard(
            Icons.people_rounded,
            'Contacts',
            _sosActive ? 'Alerted' : 'Waiting',
            _sosActive ? const Color(0xFFE91E8C) : const Color(0xFF555566),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: const Color(0xFF888899))),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _deactivateSOS,
          icon: const Icon(Icons.close),
          label: Text('CANCEL SOS', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF5252),
            side: const BorderSide(color: Color(0xFFFF5252), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}