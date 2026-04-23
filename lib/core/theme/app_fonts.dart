import 'package:flutter/material.dart';

/// ZussGo Font System
/// Splash + Onboarding : ClashDisplay (display)  +  Satoshi (body)
/// Auth / OTP / Profile: Lexend (display)         +  Inter (body)

class AppFonts {

  // ─────────────────────────────────────────
  // FAMILY CONSTANTS
  // ─────────────────────────────────────────
  static const String clashDisplay = 'ClashDisplay';
  static const String satoshi      = 'Satoshi';
  static const String lexend       = 'Lexend';
  static const String inter        = 'Inter';

  // ─────────────────────────────────────────
  // SPLASH SCREEN  (ClashDisplay + Satoshi)
  // ─────────────────────────────────────────

  static const TextStyle splashWordmarkWhite = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
    letterSpacing: -1.8,
    height: 1,
  );

  static const TextStyle splashWordmarkTeal = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: Color(0xFF58DAD0),
    letterSpacing: -1.8,
    height: 1,
  );

  static const TextStyle splashTagline = TextStyle(
    fontFamily: satoshi,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0x99A8C4BF),
    letterSpacing: 3.0,
  );

  // ─────────────────────────────────────────
  // ONBOARDING  (ClashDisplay + Satoshi)
  // ─────────────────────────────────────────

  static const TextStyle onboardingLogoWhite = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFFEDF7F4),
    letterSpacing: -0.5,
  );

  static const TextStyle onboardingLogoTeal = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF58DAD0),
    letterSpacing: -0.5,
  );

  static const TextStyle onboardingTag = TextStyle(
    fontFamily: satoshi,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle onboardingHeadline = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
    height: 1.2,
  );

  static const TextStyle onboardingDesc = TextStyle(
    fontFamily: satoshi,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xA6EDF7F4),
    height: 1.65,
  );

  static const TextStyle onboardingButton = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle onboardingSkip = TextStyle(
    fontFamily: satoshi,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0x73FFFFFF),
  );

  static const TextStyle onboardingLoginMuted = TextStyle(
    fontFamily: satoshi,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0x59FFFFFF),
  );

  static const TextStyle onboardingLoginAccent = TextStyle(
    fontFamily: satoshi,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF58DAD0),
  );

  static const TextStyle planCardTitle = TextStyle(
    fontFamily: satoshi,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
  );

  static const TextStyle planCardSub = TextStyle(
    fontFamily: satoshi,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0x73EDF7F4),
  );

  static const TextStyle planCardPill = TextStyle(
    fontFamily: satoshi,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  // ─────────────────────────────────────────
  // AUTH / OTP / PROFILE  (Lexend + Inter)
  // ─────────────────────────────────────────

  static const TextStyle authTitle = TextStyle(
    fontFamily: lexend,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
    height: 1.2,
    letterSpacing: -0.8,
  );

  static const TextStyle authSub = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFA8C4BF),
    height: 1.5,
  );

  static const TextStyle authTab = TextStyle(
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle authCountryCode = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFEDF7F4),
  );

  static const TextStyle authPhoneInput = TextStyle(
    fontFamily: inter,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFFEDF7F4),
  );

  static const TextStyle authButton = TextStyle(
    fontFamily: lexend,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle otpDigit = TextStyle(
    fontFamily: lexend,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
  );

  static const TextStyle otpResend = TextStyle(
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6A8882),
  );

  static const TextStyle formLabel = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFFA8C4BF),
    letterSpacing: 0.6,
  );

  static const TextStyle formInput = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFFEDF7F4),
  );

  static const TextStyle setupStep = TextStyle(
    fontFamily: lexend,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFF58DAD0),
    letterSpacing: 0.6,
  );

  static const TextStyle genderBtn = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ─────────────────────────────────────────
  // GENERAL PURPOSE — used across all screens
  // ─────────────────────────────────────────

  /// Large bold heading — ClashDisplay 22px w700
  static const TextStyle headingLarge = TextStyle(
    fontFamily: clashDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Section heading — Lexend 18px w700
  static const TextStyle headingMedium = TextStyle(
    fontFamily: lexend,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xFFEDF7F4),
    height: 1.3,
  );

  /// Small heading — Lexend 15px w600
  static const TextStyle headingSmall = TextStyle(
    fontFamily: lexend,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Color(0xFFEDF7F4),
  );

  /// Standard body text — Satoshi 14px w400
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: satoshi,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFA8C4BF),
    height: 1.5,
  );

  /// Small body text — Satoshi 13px w400
  static const TextStyle bodySmall = TextStyle(
    fontFamily: satoshi,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFA8C4BF),
    height: 1.5,
  );

  /// Large body text — Satoshi 16px w400
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: satoshi,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFFEDF7F4),
    height: 1.6,
  );

  /// Caption / tiny label — Satoshi 11px w600 uppercase
  static const TextStyle caption = TextStyle(
    fontFamily: satoshi,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6A8882),
    letterSpacing: 0.5,
  );

  /// Muted label — Inter 12px w500
  static const TextStyle labelMuted = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6A8882),
  );

  /// Button label general — Lexend 15px w700
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: lexend,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  /// Nav item — Inter 11px w600
  static const TextStyle navLabel = TextStyle(
    fontFamily: inter,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  /// Badge / pill — Satoshi 11px w700
  static const TextStyle badge = TextStyle(
    fontFamily: satoshi,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  /// Price / number emphasis — Lexend 20px w800
  static const TextStyle priceLabel = TextStyle(
    fontFamily: lexend,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Color(0xFFEDF7F4),
  );
}