import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});
  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _avatarPulse;
  final AudioPlayer _player = AudioPlayer();
  bool _callActive = false;
  bool _onCall = false;
  Duration _callDuration = Duration.zero;
  Timer? _durationTimer;
  Timer? _incomingTimer;

  final List<Map<String, String>> _contacts = [
    {'name': 'Mom', 'number': '+91 98765 43210', 'avatar': 'M'},
    {'name': 'Dad', 'number': '+91 87654 32109', 'avatar': 'D'},
    {'name': 'Sister', 'number': '+91 76543 21098', 'avatar': 'S'},
    {'name': 'Best Friend', 'number': '+91 65432 10987', 'avatar': 'B'},
  ];

  @override
  void initState() {
    super.initState();
    _avatarPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarPulse.dispose();
    _player.dispose();
    _durationTimer?.cancel();
    _incomingTimer?.cancel();
    super.dispose();
  }

  void _triggerFakeCall(Map<String, String> contact) {
    setState(() => _callActive = true);
    HapticFeedback.vibrate();
    // Simulate incoming call ringtone
    _incomingTimer = Timer(const Duration(seconds: 30), () {
      if (_callActive && !_onCall) _endCall();
    });
  }

  void _answerCall() {
    setState(() {
      _onCall = true;
      _callDuration = Duration.zero;
    });
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration += const Duration(seconds: 1));
    });
  }

  void _endCall() {
    _durationTimer?.cancel();
    _incomingTimer?.cancel();
    setState(() {
      _callActive = false;
      _onCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_callActive) return _buildCallUI();
    return _buildSetupUI(context);
  }

  Widget _buildSetupUI(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(
        title: Text('Fake Call', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 24),
            Text('Choose Caller',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 12),
            ...List.generate(_contacts.length, (i) => _contactTile(_contacts[i])),
            const SizedBox(height: 24),
            _delaySelector(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.15),
            const Color(0xFFE91E8C).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF7C4DFF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Trigger a fake incoming call to exit uncomfortable situations discreetly.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFFBBBBCC), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(Map<String, String> contact) {
    return GestureDetector(
      onTap: () => _triggerFakeCall(contact),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE91E8C).withOpacity(0.2),
              child: Text(contact['avatar']!,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE91E8C))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact['name']!,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(contact['number']!,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFF666677))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _delaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Or set a timer',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [5, 10, 30, 60].map((sec) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  Future.delayed(
                    Duration(seconds: sec),
                    () => _triggerFakeCall(_contacts[0]),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fake call in $sec seconds'),
                      backgroundColor: const Color(0xFF1A1A2E),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A3E)),
                  ),
                  child: Column(
                    children: [
                      Text('${sec}s',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE91E8C))),
                      Text('delay',
                          style: GoogleFonts.poppins(
                              fontSize: 9, color: const Color(0xFF555566))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCallUI() {
    final contact = _contacts[0];
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0030), Color(0xFF0D1117)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                AnimatedBuilder(
                  animation: _avatarPulse,
                  builder: (_, __) => Transform.scale(
                    scale: _onCall ? 1.0 : 0.95 + (_avatarPulse.value * 0.05),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFE91E8C).withOpacity(0.3),
                      child: Text(contact['avatar']!,
                          style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(contact['name']!,
                    style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  _onCall
                      ? _formatDuration(_callDuration)
                      : 'Incoming call...',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: const Color(0xFF888899)),
                ),
                const Spacer(),
                _buildCallControls(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    if (!_onCall) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _callBtn(Icons.call_end, const Color(0xFFFF1744), 'Decline', _endCall),
          _callBtn(Icons.call, const Color(0xFF4CAF50), 'Answer', _answerCall),
        ],
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _miniBtn(Icons.mic_off, 'Mute'),
            _miniBtn(Icons.volume_up, 'Speaker'),
            _miniBtn(Icons.dialpad, 'Keypad'),
          ],
        ),
        const SizedBox(height: 40),
        _callBtn(Icons.call_end, const Color(0xFFFF1744), 'End', _endCall),
      ],
    );
  }

  Widget _callBtn(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20)],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888899))),
      ],
    );
  }

  Widget _miniBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A2E),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF666677))),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}