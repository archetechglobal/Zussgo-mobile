// lib/features/trips/screens/trip_rating_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kBg    = Color(0xFF070E0F);
const _kS1    = Color(0xFF0D1819);
const _kGold  = Color(0xFFF7B84E);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

const _kQuickTags = [
  'Safe', 'Fun to be around', 'On Time',
  'Helpful', 'Good Communicator', 'Respectful',
];

class TripRatingScreen extends StatefulWidget {
  final String partnerName;
  final String partnerImageUrl;
  final String tripName;

  const TripRatingScreen({
    super.key,
    required this.partnerName,
    required this.partnerImageUrl,
    required this.tripName,
  });

  @override
  State<TripRatingScreen> createState() => _TripRatingScreenState();
}

class _TripRatingScreenState extends State<TripRatingScreen>
    with SingleTickerProviderStateMixin {
  int _stars = 4;
  final Set<int> _selectedTags = {0, 1};
  final _reviewCtrl = TextEditingController();
  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();
    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.lightImpact();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Stack(
            children: [
              // Gold radial glow at top
              Positioned(
                top: -80, left: 0, right: 0,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter, radius: 0.8,
                      colors: [
                        _kGold.withOpacity(.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 40 + bottomInset),
                child: Column(
                  children: [

                    // ── Header ─────────────────────────────────────────────
                    // Gold checkmark icon
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kGold, Color(0xFFE09620)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: _kGold.withOpacity(.30),
                            blurRadius: 20, offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded,
                            color: Colors.black, size: 32),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Trip Completed', style: TextStyle(
                      color: _kText, fontSize: 24,
                      fontWeight: FontWeight.w800, letterSpacing: -.3,
                    )),
                    const SizedBox(height: 8),
                    const Text('Your live tracking has been disabled.',
                        style: TextStyle(color: _kMuted, fontSize: 14)),

                    const SizedBox(height: 32),

                    // ── Partner avatar ─────────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        widget.partnerImageUrl,
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: _kGold.withOpacity(.20),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(widget.partnerName[0], style: const TextStyle(
                              color: _kGold, fontSize: 28,
                              fontWeight: FontWeight.w800,
                            )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: _kMuted, fontSize: 14, height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'How was traveling with '),
                          TextSpan(
                            text: widget.partnerName,
                            style: const TextStyle(
                              color: _kText, fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '?'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Star rating ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < _stars;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _stars = i + 1);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                key: ValueKey('$i-$filled'),
                                color: filled
                                    ? _kGold
                                    : Colors.white.withOpacity(.08),
                                size: 40,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // ── Quick feedback tags ────────────────────────────────
                    const Text('QUICK FEEDBACK', style: TextStyle(
                      color: _kFaint, fontSize: 11, fontWeight: FontWeight.w800,
                      letterSpacing: .08,
                    )),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_kQuickTags.length, (i) {
                        final sel = _selectedTags.contains(i);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              sel
                                  ? _selectedTags.remove(i)
                                  : _selectedTags.add(i);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _kGold.withOpacity(.10)
                                  : Colors.white.withOpacity(.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? _kGold.withOpacity(.30)
                                    : Colors.white.withOpacity(.08),
                              ),
                            ),
                            child: Text(
                              _kQuickTags[i],
                              style: TextStyle(
                                color: sel ? _kGold : _kMuted,
                                fontSize: 13, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // ── Written review ─────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(.08)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _reviewCtrl,
                        maxLines: 4,
                        style: const TextStyle(
                          color: _kText, fontSize: 14, height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText:
                          'Leave a public review for ${widget.partnerName}\'s profile...',
                          hintStyle: const TextStyle(
                            color: _kFaint, fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Submit ────────────────────────────────────────────
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                          color: _kGold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _kGold.withOpacity(.20),
                              blurRadius: 24, offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Submit Feedback', style: TextStyle(
                            color: Colors.black, fontSize: 16,
                            fontWeight: FontWeight.w800,
                          )),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Skip
                    GestureDetector(
                      onTap: _submit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Skip for now', style: TextStyle(
                          color: _kFaint, fontSize: 13,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}