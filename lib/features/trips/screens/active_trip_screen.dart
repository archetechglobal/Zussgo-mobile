// lib/features/trips/screens/active_trip_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'trip_rating_screen.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg      = Color(0xFF050A0A);
const _kTeal    = Color(0xFF1EC9B8);
const _kTeal2   = Color(0xFF58DAD0);
const _kText    = Color(0xFFEDF7F4);
const _kMuted   = Color(0xFFA8C4BF);
const _kFaint   = Color(0xFF6A8882);
const _kDanger  = Color(0xFFFF4D4D);
const _kBorder  = Color(0x14FFFFFF);

// ─── Entry point ─────────────────────────────────────────────────────────────

class ActiveTripScreen extends StatefulWidget {
  final String tripName;
  final String partnerName;
  final String partnerImageUrl;
  final String startTime;

  const ActiveTripScreen({
    super.key,
    this.tripName       = 'Goa Beach Crew',
    this.partnerName    = 'Aryan',
    this.partnerImageUrl = 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
    this.startTime      = 'Today, 10:00 AM',
  });

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  bool _sosConfirm = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
    _pulseScale   = Tween(begin: 1.0, end: 1.8).animate(_pulseCtrl);
    _pulseOpacity = Tween(begin: 0.7, end: 0.0).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onEndTrip() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.70),
      builder: (_) => _EndTripDialog(
        tripName: widget.tripName,
        onConfirm: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => TripRatingScreen(
                partnerName: widget.partnerName,
                partnerImageUrl: widget.partnerImageUrl,
                tripName: widget.tripName,
              ),
              transitionsBuilder: (_, a, __, child) => FadeTransition(
                opacity: a, child: child,
              ),
            ),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _onSOS() {
    setState(() => _sosConfirm = true);
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sosConfirm = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background map photo ─────────────────────────────────────────
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(.70),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => Container(color: _kBg),
            ),
          ),

          // ── Dark gradient overlay ────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.40),
                    Colors.black.withOpacity(.90),
                    _kBg,
                  ],
                  stops: const [0.0, 0.60, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Positioned(
            top: topInset + 20,
            left: 20, right: 20,
            bottom: bottomInset + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Live tracking badge + title ──────────────────────────
                Center(
                  child: Column(
                    children: [
                      // Live badge with pulsing dot
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kTeal.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kTeal.withOpacity(.22)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pulsing dot
                            SizedBox(
                              width: 16, height: 16,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseCtrl,
                                    builder: (_, __) => Transform.scale(
                                      scale: _pulseScale.value,
                                      child: Container(
                                        width: 8, height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _kTeal2.withOpacity(
                                              _pulseOpacity.value),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: _kTeal2, shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Live Tracking', style: TextStyle(
                              color: _kTeal2, fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .05,
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Trip name
                      Text(widget.tripName, style: const TextStyle(
                        color: _kText, fontSize: 28,
                        fontWeight: FontWeight.w700, letterSpacing: -.3,
                      )),
                      const SizedBox(height: 4),
                      Text('Started: ${widget.startTime}', style: const TextStyle(
                        color: _kMuted, fontSize: 14,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ── Partner card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.partnerImageUrl,
                          width: 56, height: 56, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56, height: 56,
                            color: _kTeal.withOpacity(.20),
                            child: Center(
                              child: Text(widget.partnerName[0], style: const TextStyle(
                                color: _kTeal2, fontSize: 22,
                                fontWeight: FontWeight.w800,
                              )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TRAVELING WITH', style: TextStyle(
                              color: _kFaint, fontSize: 10,
                              fontWeight: FontWeight.w800, letterSpacing: .05,
                            )),
                            const SizedBox(height: 2),
                            Text(widget.partnerName, style: const TextStyle(
                              color: _kText, fontSize: 18,
                              fontWeight: FontWeight.w700,
                            )),
                          ],
                        ),
                      ),
                      // Chat button
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            color: _kText, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Safety grid ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      // SOS — full width, most prominent
                      GestureDetector(
                        onTap: _onSOS,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _sosConfirm
                                  ? [const Color(0xFFFF6B6B), const Color(0xFFCC0000)]
                                  : [const Color(0xFFFF4D4D), const Color(0xFFCC0000)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _kDanger.withOpacity(
                                    _sosConfirm ? .50 : .30),
                                blurRadius: _sosConfirm ? 40 : 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shield_rounded,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _sosConfirm ? 'CALLING FOR HELP...' : 'EMERGENCY SOS',
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 20,
                                  fontWeight: FontWeight.w800, letterSpacing: .05,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _sosConfirm
                                    ? 'Notifying authorities & contacts'
                                    : 'Notify authorities & contacts',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.80),
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary tools row
                      Row(
                        children: [
                          Expanded(
                            child: _SafetyCard(
                              icon: Icons.location_on_rounded,
                              iconColor: _kTeal2,
                              iconBg: _kTeal.withOpacity(.10),
                              title: 'Share Live\nLocation',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SafetyCard(
                              icon: Icons.phone_rounded,
                              iconColor: _kText,
                              iconBg: Colors.white.withOpacity(.05),
                              title: 'Safety\nHotline',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── End trip ─────────────────────────────────────────────
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(.05),
                  margin: const EdgeInsets.only(bottom: 24),
                ),
                GestureDetector(
                  onTap: _onEndTrip,
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(.10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.stop_rounded, color: _kText, size: 18),
                        SizedBox(width: 8),
                        Text('End Trip', style: TextStyle(
                          color: _kText, fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Safety card ─────────────────────────────────────────────────────────────

class _SafetyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title;
  final VoidCallback onTap;

  const _SafetyCard({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(
              color: _kText, fontSize: 13, fontWeight: FontWeight.w600,
              height: 1.3,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── End trip confirm dialog ──────────────────────────────────────────────────

class _EndTripDialog extends StatelessWidget {
  final String tripName;
  final VoidCallback onConfirm, onCancel;

  const _EndTripDialog({
    required this.tripName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1819),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('End Trip?', style: TextStyle(
              color: _kText, fontSize: 20, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 8),
            Text(
              'This will stop live tracking for $tripName and take you to the rating screen.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(.08)),
                      ),
                      child: const Center(
                        child: Text('Stay', style: TextStyle(
                          color: _kText, fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4D).withOpacity(.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFF4D4D).withOpacity(.30),
                        ),
                      ),
                      child: const Center(
                        child: Text('End Trip', style: TextStyle(
                          color: Color(0xFFFF4D4D), fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}