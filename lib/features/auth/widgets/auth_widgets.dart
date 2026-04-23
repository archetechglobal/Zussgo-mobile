import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_painters.dart';

// ── Logo ─────────────────────────────────────────────────────────────────────

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(-0.2, -0.3),
              colors: [Color(0x2E58DAD0), Color(0x0F58DAD0), Colors.transparent],
              stops: [0, 0.5, 0.7],
            ),
            border: Border.all(color: AppColors.tealBorder),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x1F58DAD0), blurRadius: 32, offset: Offset(0, 8)),
              BoxShadow(color: Color(0x1458DAD0), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(painter: LogoMarkPainter()),
            ),
          ),
        ),
        const SizedBox(height: 18),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.8,
              height: 1,
            ),
            children: [
              TextSpan(text: 'Zuss'),
              TextSpan(text: 'go', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── CTA Button ────────────────────────────────────────────────────────────────

class AuthCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AuthCtaButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowTeal1, blurRadius: 32, offset: Offset(0, 12)),
            BoxShadow(color: AppColors.shadowTeal2, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textInverse,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────

class AuthSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OR Divider ────────────────────────────────────────────────────────────────

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _line()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: AppColors.textFaint,
            ),
          ),
        ),
        Expanded(child: _line()),
      ],
    );
  }

  Widget _line() => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, AppColors.border, Colors.transparent],
      ),
    ),
  );
}

// ── Text Field ────────────────────────────────────────────────────────────────

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final IconData icon;
  final VoidCallback? suffixTap;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    required this.icon,
    this.suffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.08,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13.5,
              color: AppColors.textFaint,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.borderFocus),
            ),
            suffixIcon: GestureDetector(
              onTap: suffixTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(icon, size: 15, color: AppColors.textHint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Phone Field ───────────────────────────────────────────────────────────────

class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;

  const AuthPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHONE NUMBER',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.08,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: const [
                    Text('🇮🇳', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 5),
                    Text(
                      '+91',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSub,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textFaint),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13.5,
                    color: AppColors.text,
                  ),
                  decoration: const InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.5,
                      color: AppColors.textFaint,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Atmosphere Background ─────────────────────────────────────────────────────

class AuthAtmosphere extends StatelessWidget {
  const AuthAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x0E58DAD0), Colors.transparent],
                  stops: [0, 0.65],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x08F7B84E), Colors.transparent],
                stops: [0, 0.7],
              ),
            ),
          ),
        ),
      ],
    );
  }
}