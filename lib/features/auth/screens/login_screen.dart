import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_painters.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref.read(authProvider.notifier).login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    ref.listen(authProvider, (_, next) {
      if (next is AuthSuccess) {
        context.go('/home'); // ← fixed
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthAtmosphere(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo ──────────────────────────────────────────────────
                  const Center(child: AuthLogo()),
                  const SizedBox(height: 36),

                  // ── Header ────────────────────────────────────────────────
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to continue to your Zussgo account.',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Social Login ───────────────────────────────────────────
                  AuthSocialButton(
                    label: 'Continue with Google',
                    icon: SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomPaint(painter: GoogleIconPainter()),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  const AuthOrDivider(),
                  const SizedBox(height: 20),

                  // ── Email ──────────────────────────────────────────────────
                  AuthTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  // ── Password ───────────────────────────────────────────────
                  AuthTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passCtrl,
                    obscure: _obscure,
                    icon: _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    suffixTap: () => setState(() => _obscure = !_obscure),
                  ),
                  const SizedBox(height: 10),

                  // ── Forgot Password ────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.go('/forgot-password'), // ← fixed
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Error ──────────────────────────────────────────────────
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF5C5C),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x33FF5C5C)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 15, color: Color(0xFFFF5C5C)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12.5,
                                color: Color(0xFFFF5C5C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── CTA ────────────────────────────────────────────────────
                  isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                      : AuthCtaButton(label: 'Sign In', onTap: _login),
                  const SizedBox(height: 28),

                  // ── Sign Up Link ───────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signup'), // ← fixed
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Security Badge ─────────────────────────────────────────
                  const SizedBox(height: 32),
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
        ],
      ),
    );
  }
}