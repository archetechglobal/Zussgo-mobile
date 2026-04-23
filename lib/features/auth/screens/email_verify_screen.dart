import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_painters.dart';
import '../../../core/theme/app_colors.dart';

class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailVerifyScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  int _resendTimer = 0;
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    _listenForDeepLink();
  }

  // ── Listen for the email link tap ─────────────────────────────────────────
  void _listenForDeepLink() {
    AppLinks().uriLinkStream.listen((uri) {
      // Supabase handles session from deep link automatically
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && mounted) {
        context.go('/home');
      }
    });
  }

  Future<void> _resend() async {
    await ref
        .read(authProvider.notifier)
        .resendVerification(email: widget.email);
    setState(() {
      _resent = true;
      _resendTimer = 60;
    });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      return _resendTimer > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 40),

              // ── Icon ──────────────────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  border: Border.all(color: AppColors.tealBorder),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(Icons.mark_email_unread_outlined,
                      color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────────
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a verification link to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const TextSpan(
                        text: '\n\nClick the link in the email to activate your account.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Steps ─────────────────────────────────────────────────────
              _step('1', 'Open your email app'),
              const SizedBox(height: 14),
              _step('2', 'Find the email from Zussgo'),
              const SizedBox(height: 14),
              _step('3', 'Tap "Verify my email"'),

              const Spacer(),

              // ── Resent confirmation ───────────────────────────────────────
              if (_resent)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x1579C66B),
                    border: Border.all(color: const Color(0x3379C66B)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: AppColors.success),
                      SizedBox(width: 8),
                      Text(
                        'Verification email resent!',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Resend button ─────────────────────────────────────────────
              GestureDetector(
                onTap: _resendTimer > 0 ? null : _resend,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _resendTimer > 0
                          ? 'Resend in ${_resendTimer}s'
                          : 'Resend verification email',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _resendTimer > 0
                            ? AppColors.textFaint
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Wrong email ───────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/signup'),
                  child: const Text(
                    'Wrong email? Go back',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              // ── Security badge ────────────────────────────────────────────
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CustomPaint(painter: ShieldPainter()),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Secured with Supabase Auth',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        color: AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            border: Border.all(color: AppColors.tealBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'ClashDisplay',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: AppColors.textSub,
          ),
        ),
      ],
    );
  }
}