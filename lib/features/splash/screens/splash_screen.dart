import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _contentCtrl;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  late AnimationController _ringCtrl;
  late Animation<double>   _ringScale;
  late Animation<double>   _ringOpacity;

  late AnimationController _barCtrl;
  late Animation<double>   _barAnim;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _contentFade = CurvedAnimation(
        parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _contentCtrl, curve: const Cubic(0.16, 1, 0.3, 1)));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _ringScale = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));
    _ringOpacity = Tween<double>(begin: 1.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));

    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut);

    Future.delayed(const Duration(milliseconds: 200),
            () { if (mounted) _contentCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 800),
            () { if (mounted) _barCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 3200),
            () { if (mounted) context.go('/onboarding'); });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _floatCtrl.dispose();
    _ringCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F10),
      body: Stack(
        children: [

          // Radial teal glow
          Positioned.fill(child: CustomPaint(painter: _GlowPainter())),

          // Grid texture
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Floating logo with rings
                    AnimatedBuilder(
                      animation: Listenable.merge([_floatCtrl, _ringCtrl]),
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: SizedBox(
                          width: 120, height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring
                              Opacity(
                                opacity: _ringOpacity.value,
                                child: Transform.scale(
                                  scale: _ringScale.value,
                                  child: Container(
                                    width: 120, height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0x1F1EC9B8),
                                          width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              // Inner ring
                              Opacity(
                                opacity: _ringOpacity.value * 0.6,
                                child: Transform.scale(
                                  scale: 1 + (_ringScale.value - 1) * 0.5,
                                  child: Container(
                                    width: 108, height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0x0F1EC9B8),
                                          width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              // Logo box
                              Container(
                                width: 96, height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x261EC9B8),
                                      Color(0x0A1EC9B8),
                                    ],
                                  ),
                                  border: Border.all(
                                      color: const Color(0x4D1EC9B8),
                                      width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x141EC9B8),
                                      blurRadius: 40,
                                    ),
                                  ],
                                ),
                                child: CustomPaint(painter: _ZBoltPainter()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // "Zussgo" wordmark — Clash Display
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'Zuss', style: AppFonts.splashWordmarkWhite),
                          TextSpan(text: 'go',   style: AppFonts.splashWordmarkTeal),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tagline — Satoshi
                    Text('TRAVEL TOGETHER', style: AppFonts.splashTagline),
                  ],
                ),
              ),
            ),
          ),

          // Teal loading bar at bottom
          Positioned(
            bottom: 56, left: 0, right: 0,
            child: FadeTransition(
              opacity: _contentFade,
              child: Center(
                child: SizedBox(
                  width: 140, height: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(color: const Color(0x0FFFFFFF)),
                        AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, __) => FractionallySizedBox(
                            widthFactor: _barAnim.value,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0x661EC9B8),
                                    Color(0xCC58DAD0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - size.height * 0.02);
    canvas.drawCircle(center, 280,
        Paint()..shader = RadialGradient(
          colors: const [Color(0x141EC9B8), Color(0x071EC9B8), Colors.transparent],
          stops: const [0.0, 0.4, 0.7],
        ).createShader(Rect.fromCircle(center: center, radius: 280)));
  }
  @override bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x071EC9B8)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _ZBoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 48;
    final sy = size.height / 48;
    canvas.drawPath(
      Path()
        ..moveTo(12 * sx, 16 * sy)
        ..lineTo(28 * sx, 16 * sy)
        ..lineTo(16 * sx, 32 * sy)
        ..lineTo(34 * sx, 32 * sy),
      Paint()
        ..color = const Color(0xFF58DAD0)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(34 * sx, 16 * sy),
      3.5 * math.min(sx, sy),
      Paint()..color = const Color(0xFFF7B84E),
    );
  }
  @override bool shouldRepaint(_) => false;
}