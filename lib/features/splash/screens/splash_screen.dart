import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase/supabase_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  late AnimationController _barCtrl;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Cubic(0.16, 1, 0.3, 1),
      ),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(
      CurvedAnimation(
        parent: _floatCtrl,
        curve: Curves.easeInOut,
      ),
    );

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _barAnim = CurvedAnimation(
      parent: _barCtrl,
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _barCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;

      final session = supabase.auth.currentSession;

      if (session == null) {
        context.go('/onboarding');
        return;
      }

      try {
        final data = await supabase
            .from('profiles')
            .select('is_setup_done')
            .eq('id', session.user.id)
            .maybeSingle();

        final setupDone = data?['is_setup_done'] == true;

        if (mounted) {
          context.go(setupDone ? '/home' : '/setup');
        }
      } catch (_) {
        if (mounted) context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _floatCtrl.dispose();
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
          Positioned.fill(
            child: CustomPaint(
              painter: _GlowPainter(),
            ),
          ),

          // Grid texture
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          // Center ZussGo symbol only
          Center(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Image.asset(
                        'assets/images/zussgo_symbol.png',
                        width: 210,
                        height: 210,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Teal loading bar at bottom
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _contentFade,
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(
                          color: const Color(0x0FFFFFFF),
                        ),
                        AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, __) {
                            return FractionallySizedBox(
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
                            );
                          },
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
    final center = Offset(
      size.width / 2,
      size.height / 2 - size.height * 0.02,
    );

    canvas.drawCircle(
      center,
      280,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x141EC9B8),
            Color(0x071EC9B8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: 280,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x071EC9B8)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}