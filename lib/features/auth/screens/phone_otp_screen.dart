import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/auth_painters.dart';
import '../../../core/theme/app_colors.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  int _resendTimer = 0;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Send OTP ───────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final phone = '+91${_phoneCtrl.text.trim()}';
    await ref.read(authProvider.notifier).sendOtp(phone: phone);
    setState(() {
      _otpSent = true;
      _resendTimer = 30;
    });
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      return _resendTimer > 0;
    });
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    final phone = '+91${_phoneCtrl.text.trim()}';
    final otp = _otpCtrl.map((c) => c.text).join();
    await ref.read(authProvider.notifier).verifyOtp(phone: phone, otp: otp);
  }

  // ── OTP digit input ────────────────────────────────────────────────────────

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits are filled
    if (_otpCtrl.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    ref.listen(authProvider, (_, next) {
      if (next is AuthSuccess) {
        Navigator.pushReplacementNamed(context, '/onboarding');
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
                  // ── Back ────────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      if (_otpSent) {
                        setState(() {
                          _otpSent = false;
                          for (final c in _otpCtrl) c.clear();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
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
                  const SizedBox(height: 32),

                  // ── Icon ────────────────────────────────────────────────────
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0x2258DAD0), Colors.transparent],
                        stops: [0, 0.75],
                      ),
                      border: Border.all(color: AppColors.tealBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.phone_iphone_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ───────────────────────────────────────────────────
                  Text(
                    _otpSent ? 'Enter the code' : 'Phone verification',
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _otpSent
                        ? 'A 6-digit code was sent to +91 ${_phoneCtrl.text.trim()}'
                        : 'Enter your phone number to receive a one-time verification code.',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Phone Input ─────────────────────────────────────────────
                  if (!_otpSent) ...[
                    AuthPhoneField(controller: _phoneCtrl),
                    const SizedBox(height: 24),
                    isLoading
                        ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                        : AuthCtaButton(
                      label: 'Send Code',
                      onTap: _sendOtp,
                    ),
                  ],

                  // ── OTP Input ───────────────────────────────────────────────
                  if (_otpSent) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 46,
                          height: 56,
                          child: TextFormField(
                            controller: _otpCtrl[i],
                            focusNode: _focusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (v) => _onOtpChanged(v, i),
                            style: const TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // ── Resend ─────────────────────────────────────────────────
                    Center(
                      child: _resendTimer > 0
                          ? Text(
                        'Resend code in ${_resendTimer}s',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          color: AppColors.textFaint,
                        ),
                      )
                          : GestureDetector(
                        onTap: _sendOtp,
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Verify CTA ────────────────────────────────────────────
                    isLoading
                        ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                        : AuthCtaButton(
                      label: 'Verify & Continue',
                      onTap: _verifyOtp,
                    ),
                  ],

                  // ── Error ───────────────────────────────────────────────────
                  if (error != null) ...[
                    const SizedBox(height: 16),
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
                  ],

                  // ── Security Badge ────────────────────────────────────────
                  const SizedBox(height: 40),
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
                          'SMS delivered via Supabase Auth',
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