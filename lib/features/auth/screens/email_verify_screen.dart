// lib/features/auth/screens/email_verify_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../models/app_auth_state.dart';
import '../../../core/supabase/supabase_client.dart';

const _kBg    = Color(0xFF070E0F);
const _kS1    = Color(0xFF0D1819);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailVerifyScreen({super.key, required this.email});
  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  bool _resending  = false;
  bool _resent     = false;
  bool _checking   = false;
  String? _checkError;

  Future<void> _resend() async {
    if (_resending) return;
    setState(() { _resending = true; _resent = false; _checkError = null; });
    await ref.read(authProvider.notifier).resendEmailVerification(widget.email);
    if (mounted) setState(() { _resending = false; _resent = true; });
  }

  /// Called when user taps "I've verified — Continue".
  /// Refreshes the Supabase session; if email is now confirmed routes
  /// to /setup (new user, no profile) or /home (returning user).
  Future<void> _checkVerification() async {
    if (_checking) return;
    setState(() { _checking = true; _checkError = null; });

    final confirmed = await ref.read(authProvider.notifier).checkEmailVerified();

    if (!mounted) return;

    if (confirmed) {
      // Determine if user has completed onboarding (profile exists)
      final userId = supabase.auth.currentUser?.id;
      bool hasProfile = false;
      if (userId != null) {
        final row = await supabase
            .from('profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle();
        hasProfile = row != null;
      }
      if (mounted) {
        context.go(hasProfile ? '/home' : '/setup');
      }
    } else {
      setState(() {
        _checking = false;
        _checkError = "Email not verified yet. Please check your inbox and tap the link, then try again.";
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: _kText)),
      backgroundColor: _kS1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Also listen for auth errors bubbled up via resend
    ref.listen<AppAuthState>(authProvider, (_, next) {
      if (next is AppAuthError) {
        _showSnack(next.message);
        ref.read(authProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go('/signup'),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _kText, size: 16),
                ),
              ),
              const Spacer(),

              // Icon
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: _kTeal.withOpacity(.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _kTeal.withOpacity(.25)),
                ),
                child: const Center(
                  child: Text('✉️', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Verify your email', style: TextStyle(
                color: _kText, fontSize: 28,
                fontWeight: FontWeight.w800, letterSpacing: -.4,
              )),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: _kMuted, fontSize: 15, height: 1.6),
                  children: [
                    const TextSpan(text: "We've sent a verification link to\n"),
                    TextSpan(
                      text: widget.email.isEmpty ? 'your email' : widget.email,
                      style: const TextStyle(color: _kTeal2, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '\n\nTap the link in that email to activate your account, then come back here.'),
                  ],
                ),
              ),

              const Spacer(),

              // ── Resent confirmation banner ──────────────────────────────────
              if (_resent)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kTeal.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kTeal.withOpacity(.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: _kTeal2, size: 18),
                      SizedBox(width: 10),
                      Text('Verification email resent!',
                          style: TextStyle(color: _kTeal2, fontSize: 14)),
                    ],
                  ),
                ),

              // ── Error banner ────────────────────────────────────────────────
              if (_checkError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA12C7B).withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA12C7B).withOpacity(.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFD163A7), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_checkError!,
                            style: const TextStyle(
                              color: Color(0xFFD163A7), fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                ),

              // ── Resend button ───────────────────────────────────────────────
              GestureDetector(
                onTap: (_resending || _checking) ? null : _resend,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: Center(
                    child: _resending
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(color: _kTeal2, strokeWidth: 2))
                        : const Text('Resend email', style: TextStyle(
                            color: _kMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Primary CTA: check verification ────────────────────────────
              GestureDetector(
                onTap: (_checking || _resending) ? null : _checkVerification,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: (_checking || _resending)
                        ? null
                        : const LinearGradient(colors: [_kTeal2, _kTeal]),
                    color: (_checking || _resending)
                        ? Colors.white.withOpacity(.05)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: (_checking || _resending)
                        ? []
                        : [BoxShadow(
                            color: _kTeal.withOpacity(.25),
                            blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Center(
                    child: _checking
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Color(0xFF041818), strokeWidth: 2))
                        : const Text("I've verified — Continue", style: TextStyle(
                            color: Color(0xFF041818), fontSize: 15,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
