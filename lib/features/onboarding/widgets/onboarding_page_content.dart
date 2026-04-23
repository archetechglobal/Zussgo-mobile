import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../screens/onboarding_screen.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingPageContent({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // ── Accent-colored icon box (replaces emoji placeholder) ──
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accentColor.withOpacity(0.12),
                ),
                child: Icon(
                  slide.icon,
                  color: slide.accentColor,
                  size: 36,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Slide tag (e.g., "DISCOVER INDIA") ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: slide.accentColor.withOpacity(0.12),
              border: Border.all(color: slide.accentColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              slide.tag,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: slide.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Headline white line ──
          Text(
            slide.headlineWhite,
            style: const TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEDF7F4),
              height: 1.2,
            ),
          ),

          // ── Headline accent line ──
          Text(
            slide.headlineAccent,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: slide.accentColor,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // ── Description ──
          Text(
            slide.desc,
            style: AppFonts.bodyMedium.copyWith(
              color: const Color(0xFFA8C4BF),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}