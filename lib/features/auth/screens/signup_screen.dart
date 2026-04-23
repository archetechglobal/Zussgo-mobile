import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_painters.dart';
import '../../../core/theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy to continue.'),
          backgroundColor: Color(0xFFFF5C5C),
        ),
      );
      return;
    }
    await ref.read(authProvider.notifier).signup(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
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
      if (next is AuthAwaitingVerification) {
        context.go('/verify-email', extra: next.email); // ← verification flow
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
                  // ── Back ──────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => context.go('/login'), // ← fixed
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Header ────────────────────────────────────────────────
                  const Text(
                    'Create account',
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
                    'Join Zussgo and start finding travel companions.',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Google ────────────────────────────────────────────────
                  AuthSocialButton(
                    label: 'Sign up with Google',
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

                  // ── Full Name ─────────────────────────────────────────────
                  AuthTextField(
                    label: 'Full Name',
                    hint: 'Alex Johnson',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ─────────────────────────────────────────────────
                  AuthTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  // ── Phone ─────────────────────────────────────────────────
                  AuthPhoneField(controller: _phoneCtrl),
                  const SizedBox(height: 16),

                  // ── Password ──────────────────────────────────────────────
                  AuthTextField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    controller: _passCtrl,
                    obscure: _obscure,
                    icon: _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    suffixTap: () => setState(() => _obscure = !_obscure),
                  ),
                  const SizedBox(height: 20),

                  // ── Terms ─────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: _agreed
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: _agreed
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _agreed
                              ? const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Error ─────────────────────────────────────────────────
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

                  // ── CTA ───────────────────────────────────────────────────
                  isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                      : AuthCtaButton(
                      label: 'Create Account', onTap: _signup),
                  const SizedBox(height: 28),

                  // ── Login Link ────────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'), // ← fixed
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
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

                  // ── Security Badge ────────────────────────────────────────
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
                          'End-to-end encrypted · Supabase Auth',
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