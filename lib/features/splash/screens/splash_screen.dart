import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _ctrl.forward();
    _waitAndNavigate();
  }

  void _waitAndNavigate() {
    // Listen for initial session restoration from Supabase
    bool navigated = false;

    _authSub = supabase.auth.onAuthStateChange.listen((data) async {
      if (navigated) return;
      if (data.event == AuthChangeEvent.initialSession ||
          data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.signedOut) {
        navigated = true;
        _authSub?.cancel();
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        await _navigate(data.session);
      }
    });

    // Fallback: if no auth event fires after 4s, navigate anyway
    Future.delayed(const Duration(seconds: 4), () async {
      if (navigated || !mounted) return;
      navigated = true;
      _authSub?.cancel();
      await _navigate(supabase.auth.currentSession);
    });
  }

  Future<void> _navigate(Session? session) async {
    if (!mounted) return;
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
      if (!mounted) return;
      final setupDone = data?['is_setup_done'] == true;
      context.go(setupDone ? '/home' : '/setup');
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E0F),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1EC9B8).withOpacity(0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Z', style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    )),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('ZussGo', style: TextStyle(
                  color: Color(0xFFEDF7F4),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                )),
                const SizedBox(height: 6),
                const Text('Connect. Explore. Travel Together.', style: TextStyle(
                  color: Color(0xFF6A8882),
                  fontSize: 13,
                  letterSpacing: .2,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}