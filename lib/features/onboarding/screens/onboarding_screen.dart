import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════
// DATA MODEL
// ══════════════════════════════════════════

class OnboardingSlide {
  final String tag;
  final String headlineWhite;
  final String headlineAccent;
  final String desc;
  final Color accentColor;
  final List<Color> btnColors;
  final Color btnTextColor;
  final Color btnShadow;
  final String btnLabel;
  final bool showChevron;
  final IconData icon;
  final String imageUrl;
  final bool showPlanCards;

  const OnboardingSlide({
    required this.tag,
    required this.headlineWhite,
    required this.headlineAccent,
    required this.desc,
    required this.accentColor,
    required this.btnColors,
    required this.btnTextColor,
    required this.btnShadow,
    required this.btnLabel,
    required this.showChevron,
    required this.icon,
    required this.imageUrl,
    this.showPlanCards = false,
  });
}

// ══════════════════════════════════════════
// SLIDE DATA  — 4K Unsplash images (w=3840)
// ══════════════════════════════════════════

const List<OnboardingSlide> _slides = [
  OnboardingSlide(
    tag: 'DISCOVER INDIA',
    headlineWhite: 'Every destination.',
    headlineAccent: 'One app.',
    desc:
        'From Himalayan peaks to coastal escapes — explore trending destinations with people who travel like you.',
    accentColor: Color(0xFF58DAD0),
    btnColors: [Color(0xFF58DAD0), Color(0xFF58DAD0)],
    btnTextColor: Color(0xFF050C0D),
    btnShadow: Color(0x4D58DAD0),
    btnLabel: 'Next',
    showChevron: true,
    icon: Icons.explore_outlined,
    // Himalayan mountain lake — 4K
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=100&w=3840&auto=format&fit=crop',
  ),
  OnboardingSlide(
    tag: 'SMART MATCHING',
    headlineWhite: 'Find your',
    headlineAccent: 'perfect travel companion',
    desc:
        'Our algorithm matches you with travelers who share your vibe, budget and destination — not just anyone.',
    accentColor: Color(0xFFF7B84E),
    btnColors: [Color(0xFFF7B84E), Color(0xFFF7B84E)],
    btnTextColor: Color(0xFF050C0D),
    btnShadow: Color(0x4DF7B84E),
    btnLabel: 'Next',
    showChevron: true,
    icon: Icons.people_outline,
    // Group of travelers — 4K
    imageUrl:
        'https://images.unsplash.com/photo-1539635278303-d4002c07eae3?q=100&w=3840&auto=format&fit=crop',
  ),
  OnboardingSlide(
    tag: 'BUILT-IN SAFETY',
    headlineWhite: 'Your safety is',
    headlineAccent: 'our priority',
    desc:
        'One-tap SOS with live location sharing. Your trusted contacts are always one tap away.',
    accentColor: Color(0xFFFF6B8A),
    btnColors: [Color(0xFFFF6B8A), Color(0xFFFF4D4D)],
    btnTextColor: Colors.white,
    btnShadow: Color(0x40FF4D4D),
    btnLabel: 'Next',
    showChevron: true,
    icon: Icons.shield_outlined,
    // Adventure travelers — 4K
    imageUrl:
        'https://images.unsplash.com/photo-1501555088652-021faa106b9b?q=100&w=3840&auto=format&fit=crop',
  ),
  OnboardingSlide(
    tag: 'PLAN TOGETHER',
    headlineWhite: 'Chat, plan &',
    headlineAccent: 'go together',
    desc:
        'Coordinate dates, split costs and chat with your companions — all without leaving the app.',
    accentColor: Color(0xFF58DAD0),
    btnColors: [Color(0xFF58DAD0), Color(0xFF3BBFB5)],
    btnTextColor: Color(0xFF050C0D),
    btnShadow: Color(0x4D58DAD0),
    btnLabel: 'Get Started',
    showChevron: false,
    icon: Icons.chat_bubble_outline,
    // Travel planning together — 4K
    imageUrl:
        'https://images.unsplash.com/photo-1488646953014-85cb44e25828?q=100&w=3840&auto=format&fit=crop',
    showPlanCards: true,
  ),
];

// ══════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  /// Mark onboarding as seen and navigate to login.
  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF050C0D),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [

          // ── Full-screen PageView ──
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _buildSlide(_slides[i]),
          ),

          // ── Top bar: logo + skip ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Logo
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x2658DAD0),
                        border: Border.all(color: const Color(0x4D58DAD0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.route_rounded,
                          color: Color(0xFF58DAD0), size: 16),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEDF7F4),
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(text: 'Zuss'),
                          TextSpan(
                              text: 'go',
                              style: TextStyle(color: Color(0xFF58DAD0))),
                        ],
                      ),
                    ),
                  ],
                ),

                // Skip button
                GestureDetector(
                  onTap: _finish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0x73FFFFFF),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),

          // ── Bottom controls: dots + button + login ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, bottomPad + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 5),
                        width: isActive ? 20 : 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? slide.accentColor
                              : const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // CTA button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: slide.btnColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: slide.btnShadow,
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.btnLabel,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: slide.btnTextColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (slide.showChevron) ...
                            [
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded,
                                  color: slide.btnTextColor, size: 18),
                            ],
                        ],
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

  Widget _buildSlide(OnboardingSlide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image — full resolution via Image.network
        Image.network(
          slide.imageUrl,
          fit: BoxFit.cover,
          // Hint Flutter to decode at full device pixel ratio
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF050C0D),
          ),
        ),

        // Dark gradient overlay for text readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Color(0x33000000),
                Color(0xCC000000),
                Color(0xF2000000),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Slide text content
        Positioned(
          bottom: 170,
          left: 22,
          right: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: slide.accentColor.withOpacity(0.18),
                  border: Border.all(
                      color: slide.accentColor.withOpacity(0.4), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide.tag,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: slide.accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Headline
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: '${slide.headlineWhite}\n',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: slide.headlineAccent,
                      style: TextStyle(color: slide.accentColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                slide.desc,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB3FFFFFF),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
