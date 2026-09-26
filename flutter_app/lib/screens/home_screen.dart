import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/safety_status_card.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/nearby_alert_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A14), Color(0xFF0D0D24), Color(0xFF0A0A14)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      NearbyAlertBanner(),
                      const SizedBox(height: 24),
                      _buildSOSButton(),
                      const SizedBox(height: 28),
                      SafetyStatusCard(),
                      const SizedBox(height: 28),
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 16),
                      QuickActionGrid(),
                      const SizedBox(height: 28),
                      _sectionTitle('Recent Activity'),
                      const SizedBox(height: 16),
                      _buildRecentActivity(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      expandedHeight: 80,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SafeHer',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE91E8C))),
                Text('Stay safe, stay connected',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF666677))),
              ],
            ),
            Row(children: [
              _iconBtn(Icons.notifications_outlined, () {}),
              const SizedBox(width: 8),
              _iconBtn(Icons.person_outline, () => context.push('/settings')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: GestureDetector(
        onTap: () => context.push('/sos'),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value + (i * 0.12),
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE91E8C)
                            .withOpacity(0.15 - (i * 0.04)),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF3B7A), Color(0xFFE91E8C), Color(0xFFAA0055)],
                  stops: [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E8C).withOpacity(0.5),
                    blurRadius: 30, spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 6),
                  Text('SOS',
                      style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2)),
                  Text('TAP FOR HELP',
                      style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: Colors.white60,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white));
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'icon': Icons.location_on, 'title': 'Location shared', 'time': '2m ago', 'color': 0xFF4CAF50},
      {'icon': Icons.person_add, 'title': 'Contact added: Mom', 'time': '1h ago', 'color': 0xFF2196F3},
      {'icon': Icons.shield, 'title': 'Safe zone updated', 'time': '3h ago', 'color': 0xFFE91E8C},
    ];
    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A3E)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Color(a['color'] as int).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(a['icon'] as IconData,
                    color: Color(a['color'] as int), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(a['title'] as String,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
              Text(a['time'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF555566))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: const Border(top: BorderSide(color: Color(0xFF2A2A3E))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', true, () {}),
              _navItem(Icons.map_rounded, 'Map', false, () => context.push('/map')),
              _navItem(Icons.contacts_rounded, 'Contacts', false, () => context.push('/contacts')),
              _navItem(Icons.phone_callback_rounded, 'Fake Call', false, () => context.push('/fake-call')),
              _navItem(Icons.bar_chart_rounded, 'Report', false, () => context.push('/report')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFE91E8C).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: active ? const Color(0xFFE91E8C) : const Color(0xFF555566),
                size: 22),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: active ? const Color(0xFFE91E8C) : const Color(0xFF555566),
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}