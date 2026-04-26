import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

const _kBg    = Color(0xFF070E0F);
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
  bool _resending = false;
  bool _resent    = false;

  Future<void> _resend() async {
    if (_resending) return;
    setState(() { _resending = true; _resent = false; });
    await ref.read(authProvider.notifier).resendEmailVerification(widget.email);
    if (mounted) setState(() { _resending = false; _resent = true; });
  }

  @override
  Widget build(BuildContext context) {
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
                    const TextSpan(text: '\n\nTap the link in that email to activate your account.'),
                  ],
                ),
              ),
              const Spacer(),
              if (_resent)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
              GestureDetector(
                onTap: _resend,
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
                        child: CircularProgressIndicator(
                            color: _kTeal2, strokeWidth: 2))
                        : const Text("Resend email", style: TextStyle(
                      color: _kMuted, fontSize: 14, fontWeight: FontWeight.w600,
                    )),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kTeal2, _kTeal]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: _kTeal.withOpacity(.25),
                      blurRadius: 20, offset: const Offset(0, 8),
                    )],
                  ),
                  child: const Center(
                    child: Text("I've verified — Log in", style: TextStyle(
                      color: Color(0xFF041818), fontSize: 15,
                      fontWeight: FontWeight.w800,
                    )),
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