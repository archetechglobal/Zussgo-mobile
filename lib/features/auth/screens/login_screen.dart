// lib/features/auth/screens/login_screen.dart

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

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    await ref.read(authProvider.notifier).signInWithEmail(
      email: email, password: password,
    );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
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
      if (next is AppAuthSuccess) {
        context.go('/home');
      } else if (next is AppAuthNewGoogleUser) {
        // New Google user — send to setup with prefilled data
        context.go('/setup', extra: {
          'name':     next.displayName,
          'photoUrl': next.photoUrl,
        });
      } else if (next is AppAuthAwaitingVerification) {
        context.go('/verify-email', extra: next.email);
      } else if (next is AppAuthError) {
        _showSnack(next.message);
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = authState is AppAuthLoading;
    final bottom    = MediaQuery.of(context).padding.bottom;

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
                  const Text('Welcome back', style: TextStyle(
                    color: _kText, fontSize: 30,
                    fontWeight: FontWeight.w800, letterSpacing: -.5,
                  )),
                  const SizedBox(height: 6),
                  const Text("Let's get you back on the road",
                      style: TextStyle(color: _kMuted, fontSize: 14)),
                  const SizedBox(height: 36),
                  _GoogleButton(
                    onTap: isLoading ? null : _googleSignIn,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  const _Label('EMAIL'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _emailCtrl,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const _Label('PASSWORD'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _passwordCtrl,
                    hint: 'Your password',
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _kFaint, size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PrimaryButton(
                    label: 'Log In',
                    isLoading: isLoading,
                    onTap: isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.go('/phone-verify'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.white.withOpacity(.08)),
                      ),
                      child: const Center(
                        child: Text('Continue with Phone',
                            style: TextStyle(
                              color: _kMuted, fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: _kMuted, fontSize: 14),
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(text: 'Sign up',
                                style: TextStyle(
                                    color: _kTeal2,
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

// ─────────────────────────────────────────────────────────────────────────────
// Signup Screen
// ─────────────────────────────────────────────────────────────────────────────

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) { _showSnack('Please accept the terms to continue'); return; }
    final name     = _nameCtrl.text.trim();
    final phone    = _phoneCtrl.text.trim();
    final ageText  = _ageCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || ageText.isEmpty ||
        email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 18 || age > 99) {
      _showSnack('Please enter a valid age (18+)');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    await ref.read(authProvider.notifier).signUpWithEmail(
      email: email,
      password: password,
      name: name,
      phone: phone,
      age: age,
    );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
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
    final authState = ref.watch(authProvider);

    ref.listen<AppAuthState>(authProvider, (_, next) {
      if (next is AppAuthSuccess) {
        context.go('/setup');
      } else if (next is AppAuthNewGoogleUser) {
        // New Google user — send to setup with prefilled data
        context.go('/setup', extra: {
          'name':     next.displayName,
          'photoUrl': next.photoUrl,
        });
      } else if (next is AppAuthAwaitingVerification) {
        context.go('/verify-email', extra: next.email);
      } else if (next is AppAuthError) {
        _showSnack(next.message);
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = authState is AppAuthLoading;
    final bottom    = MediaQuery.of(context).padding.bottom;

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

                  // Google button
                  _GoogleButton(
                    onTap: isLoading ? null : _googleSignIn,
                    isLoading: isLoading,
                    label: 'Continue with Google',
                  ),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),

                  // ── Full name ────────────────────────────────────────────
                  const _Label('FULL NAME'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _nameCtrl,
                    hint: 'Your full name',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),

                  // ── Phone + Age row ──────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label('PHONE'),
                            const SizedBox(height: 8),
                            _InputField(
                              ctrl: _phoneCtrl,
                              hint: '+1 555 000 0000',
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label('AGE'),
                            const SizedBox(height: 8),
                            _InputField(
                              ctrl: _ageCtrl,
                              hint: '18',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Email ────────────────────────────────────────────────
                  const _Label('EMAIL'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _emailCtrl,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // ── Password ─────────────────────────────────────────────
                  const _Label('PASSWORD'),
                  const SizedBox(height: 8),
                  _InputField(
                    ctrl: _passwordCtrl,
                    hint: 'Min. 6 characters',
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _kFaint, size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Terms checkbox ───────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _agreed
                                ? _kTeal.withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreed
                                  ? _kTeal
                                  : Colors.white.withOpacity(.15),
                              width: _agreed ? 1.5 : 1,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(Icons.check_rounded,
                              color: _kTeal2, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  color: _kMuted, fontSize: 13),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                        color: _kTeal2,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(text: ' and '),
                                TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                        color: _kTeal2,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _PrimaryButton(
                    label: 'Create Account',
                    isLoading: isLoading,
                    enabled: _agreed,
                    onTap: (isLoading || !_agreed) ? null : _submit,
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: _kMuted, fontSize: 14),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                    color: _kTeal2,
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String label;

  const _GoogleButton({
    required this.onTap,
    this.isLoading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          color: isLoading
              ? Colors.white.withOpacity(.04)
              : Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(isLoading ? .04 : .12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleLogo(),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isLoading ? _kFaint : _kText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r  = w / 2;

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()..color = Colors.white,
    );

    final paintBlue   = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final paintRed    = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final paintGreen  = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;

    final scale = w / 20.0;
    canvas.save();
    canvas.translate(cx - 10 * scale, cy - 10 * scale);
    canvas.scale(scale);

    final pathRed = Path()
      ..moveTo(10, 10)
      ..lineTo(3.4, 2.4)
      ..arcTo(Rect.fromCircle(center: const Offset(10, 10), radius: 8), -2.21, 1.40, false)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    final pathGreen = Path()
      ..moveTo(10, 10)
      ..lineTo(2, 10)
      ..arcTo(Rect.fromCircle(center: const Offset(10, 10), radius: 8), 3.14, 1.57, false)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    final pathYellow = Path()
      ..moveTo(10, 10)
      ..lineTo(16.6, 17.6)
      ..arcTo(Rect.fromCircle(center: const Offset(10, 10), radius: 8), 0.93, 1.25, false)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    final pathBlue = Path()
      ..moveTo(10, 10)
      ..lineTo(18, 10)
      ..arcTo(Rect.fromCircle(center: const Offset(10, 10), radius: 8), 0, 0.93, false)
      ..lineTo(10, 10);
    canvas.drawPath(pathBlue, paintBlue);

    canvas.drawRect(Rect.fromLTWH(10, 8.5, 8, 3), Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(10, 10), 4, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(
            color: _kFaint, fontSize: 12, fontWeight: FontWeight.w500,
          )),
        ),
        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(.08))),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = !isLoading && enabled;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_kTeal2, _kTeal])
              : null,
          color: active ? null : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [BoxShadow(color: _kTeal.withOpacity(.28), blurRadius: 24, offset: const Offset(0, 10))]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Color(0xFF041818), strokeWidth: 2),
                )
              : Text(label, style: TextStyle(
                  color: active ? const Color(0xFF041818) : _kFaint,
                  fontSize: 15, fontWeight: FontWeight.w800,
                )),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        color: _kFaint, fontSize: 10,
        fontWeight: FontWeight.w800, letterSpacing: .08,
      ));
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.ctrl,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
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
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: _kText, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kFaint, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
