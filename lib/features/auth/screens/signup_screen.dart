import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/app_auth_state.dart';

const _kBg    = Color(0xFF070E0F);
const _kS1    = Color(0xFF0D1819);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed  = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) {
      _showSnack('Please accept the terms to continue');
      return;
    }
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    await ref.read(authProvider.notifier).signUpWithEmail(
      email: email, password: password,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _kText)),
        backgroundColor: _kS1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AppAuthState>(authProvider, (_, next) {
      if (next is AppAuthAwaitingVerification) {
        context.go('/verify-email', extra: next.email);
      } else if (next is AppAuthSuccess) {
        context.go('/setup');
      } else if (next is AppAuthError) {
        _showSnack(next.message);
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = authState is AppAuthLoading;
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -60, left: 0, right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter, radius: 0.8,
                  colors: [_kTeal.withOpacity(.10), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
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
                  const SizedBox(height: 32),
                  const Text('Create account', style: TextStyle(
                    color: _kText, fontSize: 30,
                    fontWeight: FontWeight.w800, letterSpacing: -.5,
                  )),
                  const SizedBox(height: 6),
                  const Text('Join thousands of travelers on ZussGo',
                      style: TextStyle(color: _kMuted, fontSize: 14)),
                  const SizedBox(height: 36),

                  _Label('EMAIL'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _emailCtrl,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _Label('PASSWORD'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _passwordCtrl,
                    hint: 'Min. 6 characters',
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _kFaint, size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _agreed ? _kTeal.withOpacity(.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreed ? _kTeal : Colors.white.withOpacity(.15),
                              width: _agreed ? 1.5 : 1,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(Icons.check_rounded, color: _kTeal2, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: _kMuted, fontSize: 13),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(text: 'Terms of Service',
                                    style: TextStyle(color: _kTeal2,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(text: ' and '),
                                TextSpan(text: 'Privacy Policy',
                                    style: TextStyle(color: _kTeal2,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA
                  GestureDetector(
                    onTap: isLoading ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: (!isLoading && _agreed)
                            ? const LinearGradient(colors: [_kTeal2, _kTeal])
                            : null,
                        color: (isLoading || !_agreed)
                            ? Colors.white.withOpacity(.05)
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: (!isLoading && _agreed) ? [
                          BoxShadow(
                            color: _kTeal.withOpacity(.28),
                            blurRadius: 24, offset: const Offset(0, 10),
                          ),
                        ] : [],
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF041818), strokeWidth: 2,
                          ),
                        )
                            : const Text('Create Account', style: TextStyle(
                          color: Color(0xFF041818), fontSize: 15,
                          fontWeight: FontWeight.w800,
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login redirect
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: _kMuted, fontSize: 14),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(text: 'Log in',
                                style: TextStyle(color: _kTeal2,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _kFaint, fontSize: 10,
      fontWeight: FontWeight.w800, letterSpacing: .08,
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.ctrl, required this.hint,
    this.obscure = false, this.keyboardType, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: _kText, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kFaint, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
          suffixIcon: suffix,
          isDense: false,
        ),
      ),
    );
  }
}