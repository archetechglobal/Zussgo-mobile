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

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});
  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool _otpSent    = false;
  String _phone    = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    _phone = '+91${_phoneCtrl.text.trim()}';
    await ref.read(authProvider.notifier).signInWithPhone(_phone);
  }

  Future<void> _verifyOtp() async {
    await ref.read(authProvider.notifier).verifyPhoneOtp(
      phone: _phone, token: _otpCtrl.text.trim(),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _kText)),
        backgroundColor: _kS1, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AppAuthState>(authProvider, (_, next) {
      if (next is AppAuthAwaitingVerification && !_otpSent) {
        setState(() => _otpSent = true);
      } else if (next is AppAuthSuccess) {
        context.go('/home');
      } else if (next is AppAuthError) {
        _showSnack(next.message);
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = authState is AppAuthLoading;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24,
              MediaQuery.of(context).padding.bottom + 24),
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
              Text(_otpSent ? 'Enter OTP' : 'Phone Login', style: const TextStyle(
                color: _kText, fontSize: 28, fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              )),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'Enter the 6-digit code sent to $_phone'
                    : 'We\'ll send a one-time code to your number',
                style: const TextStyle(color: _kMuted, fontSize: 14),
              ),
              const SizedBox(height: 36),
              if (!_otpSent) ...[
                const Text('MOBILE NUMBER', style: TextStyle(
                  color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: .08,
                )),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('+91', style: TextStyle(
                          color: _kTeal2, fontSize: 15, fontWeight: FontWeight.w700,
                        )),
                      ),
                      Container(width: 1, height: 24,
                          color: Colors.white.withOpacity(.08)),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: _kText, fontSize: 15),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            hintText: '9XXXXXXXXX',
                            hintStyle: TextStyle(color: _kFaint, fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text('6-DIGIT CODE', style: TextStyle(
                  color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: .08,
                )),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: _kText, fontSize: 22,
                        letterSpacing: 8, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: '------',
                      hintStyle: TextStyle(color: _kFaint, fontSize: 22,
                          letterSpacing: 8),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: !isLoading
                        ? const LinearGradient(colors: [_kTeal2, _kTeal])
                        : null,
                    color: isLoading ? Colors.white.withOpacity(.05) : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: !isLoading ? [BoxShadow(
                      color: _kTeal.withOpacity(.28),
                      blurRadius: 24, offset: const Offset(0, 10),
                    )] : [],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF041818), strokeWidth: 2))
                        : Text(_otpSent ? 'Verify OTP' : 'Send Code',
                      style: const TextStyle(color: Color(0xFF041818),
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
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