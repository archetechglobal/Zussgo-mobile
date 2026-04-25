// lib/features/setup/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg    = Color(0xFF070E0F);
const _kS1    = Color(0xFF0D1819);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kGold  = Color(0xFFF7B84E);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

// ─── Setup screen ─────────────────────────────────────────────────────────────

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  final _totalSteps = 5;

  // Collected data
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl  = TextEditingController();
  bool _hasPhoto  = false;
  final Set<String> _vibes   = {};
  String _budget   = '';
  String _pace     = '';
  String _accomm   = '';

  late final AnimationController _progressCtrl;
  late final AnimationController _stepCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _progressCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _stepCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320),
    )..value = 1.0;
    _progressAnim = Tween(begin: 0.0, end: 1 / _totalSteps)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose();
    _cityCtrl.dispose(); _bioCtrl.dispose();
    _progressCtrl.dispose(); _stepCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _progressCtrl.animateTo(
        (_step + 2) / _totalSteps,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      _stepCtrl.forward(from: 0);
      setState(() => _step++);
    } else {
      context.go('/home');
    }
  }

  void _back() {
    if (_step > 0) {
      _progressCtrl.animateTo(
        _step / _totalSteps,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _step--);
    }
  }

  bool get _canContinue {
    switch (_step) {
      case 0: return _nameCtrl.text.trim().isNotEmpty &&
          _ageCtrl.text.trim().isNotEmpty &&
          _cityCtrl.text.trim().isNotEmpty;
      case 1: return true; // photo optional
      case 2: return _vibes.isNotEmpty;
      case 3: return _budget.isNotEmpty && _pace.isNotEmpty && _accomm.isNotEmpty;
      case 4: return true;
      default: return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Teal glow top
          Positioned(
            top: -80, left: 0, right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter, radius: 0.9,
                  colors: [_kTeal.withOpacity(.12), Colors.transparent],
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: top + 16),

              // ── Header row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (_step > 0)
                      GestureDetector(
                        onTap: _back,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _kText, size: 16,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 36),

                    const Spacer(),

                    // Step counter
                    Text(
                      '${_step + 1} of $_totalSteps',
                      style: const TextStyle(
                        color: _kFaint, fontSize: 12, fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    // Skip (steps 1, 4)
                    if (_step == 1 || _step == 4)
                      GestureDetector(
                        onTap: _next,
                        child: const Text('Skip', style: TextStyle(
                          color: _kFaint, fontSize: 13, fontWeight: FontWeight.w600,
                        )),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Progress bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 4,
                    color: Colors.white.withOpacity(.08),
                    child: AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressCtrl.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kTeal2, _kTeal],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Step content ───────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(.04, 0), end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(bottom),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(double bottom) {
    switch (_step) {
      case 0: return _StepBasics(
        nameCtrl: _nameCtrl, ageCtrl: _ageCtrl, cityCtrl: _cityCtrl,
        canContinue: _canContinue, bottom: bottom, onNext: _next,
        onChanged: () => setState(() {}),
      );
      case 1: return _StepPhoto(
        hasPhoto: _hasPhoto, bottom: bottom,
        onAdd: () => setState(() => _hasPhoto = true),
        onNext: _next,
      );
      case 2: return _StepVibes(
        selected: _vibes, bottom: bottom,
        onToggle: (v) => setState(() =>
        _vibes.contains(v) ? _vibes.remove(v) : _vibes.add(v)),
        onNext: _next,
      );
      case 3: return _StepStyle(
        budget: _budget, pace: _pace, accomm: _accomm,
        bottom: bottom,
        onBudget: (v) => setState(() => _budget = v),
        onPace:   (v) => setState(() => _pace = v),
        onAccomm: (v) => setState(() => _accomm = v),
        canContinue: _canContinue, onNext: _next,
      );
      case 4: return _StepBio(
        bioCtrl: _bioCtrl, name: _nameCtrl.text,
        bottom: bottom, onNext: _next,
      );
      default: return const SizedBox();
    }
  }
}

// ─── Step 1: Basics ───────────────────────────────────────────────────────────

class _StepBasics extends StatelessWidget {
  final TextEditingController nameCtrl, ageCtrl, cityCtrl;
  final bool canContinue;
  final double bottom;
  final VoidCallback onNext, onChanged;

  const _StepBasics({
    required this.nameCtrl, required this.ageCtrl, required this.cityCtrl,
    required this.canContinue, required this.bottom,
    required this.onNext, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      emoji: '👋',
      title: "Let's set up\nyour profile",
      subtitle: 'This is what other travelers will see first.',
      bottom: bottom,
      canContinue: canContinue,
      onNext: onNext,
      btnLabel: 'Continue',
      child: Column(
        children: [
          _Field(ctrl: nameCtrl, label: 'Your Name',  hint: 'e.g. Aryan', onChanged: onChanged),
          const SizedBox(height: 16),
          _Field(ctrl: ageCtrl,  label: 'Age', hint: 'e.g. 24',
              keyboardType: TextInputType.number, onChanged: onChanged),
          const SizedBox(height: 16),
          _Field(ctrl: cityCtrl, label: 'Home Base', hint: 'e.g. Mumbai, India', onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Step 2: Photo ────────────────────────────────────────────────────────────

class _StepPhoto extends StatelessWidget {
  final bool hasPhoto;
  final double bottom;
  final VoidCallback onAdd, onNext;

  const _StepPhoto({
    required this.hasPhoto, required this.bottom,
    required this.onAdd, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      emoji: '📸',
      title: 'Add your\nprofile photo',
      subtitle: 'Profiles with photos get 3× more connections.',
      bottom: bottom, canContinue: true, onNext: onNext,
      btnLabel: hasPhoto ? 'Looks great →' : 'Skip for now',
      child: Center(
        child: GestureDetector(
          onTap: onAdd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 160, height: 160,
            decoration: BoxDecoration(
              color: hasPhoto
                  ? _kTeal.withOpacity(.15)
                  : Colors.white.withOpacity(.03),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: hasPhoto
                    ? _kTeal.withOpacity(.40)
                    : Colors.white.withOpacity(.12),
                width: hasPhoto ? 2 : 1,
              ),
            ),
            child: hasPhoto
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded, color: _kTeal2, size: 40),
                SizedBox(height: 8),
                Text('Photo added!', style: TextStyle(
                  color: _kTeal2, fontSize: 13, fontWeight: FontWeight.w700,
                )),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: _kFaint, size: 36),
                const SizedBox(height: 10),
                const Text('Tap to upload', style: TextStyle(
                  color: _kFaint, fontSize: 13,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 3: Vibes ────────────────────────────────────────────────────────────

class _StepVibes extends StatelessWidget {
  final Set<String> selected;
  final double bottom;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  const _StepVibes({
    required this.selected, required this.bottom,
    required this.onToggle, required this.onNext,
  });

  static const _vibes = [
    (emoji: '🌊', label: 'Beach & Social',     color: Color(0xFF1EC9B8)),
    (emoji: '🏔️', label: 'Mountains & Trek',   color: Color(0xFF9FD9BE)),
    (emoji: '🎪', label: 'Culture & Festivals', color: Color(0xFFF7B84E)),
    (emoji: '✨', label: 'Wellness & Retreat',  color: Color(0xFFFFB3C1)),
    (emoji: '🎉', label: 'Party & Nightlife',   color: Color(0xFFB57BFF)),
    (emoji: '🏕️', label: 'Camping & Nature',   color: Color(0xFF9FD9BE)),
    (emoji: '🏛️', label: 'Heritage & History', color: Color(0xFFF7B84E)),
    (emoji: '☕', label: 'Slow & Cafes',        color: Color(0xFF58DAD0)),
  ];

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      emoji: '✌️',
      title: 'What\'s your\ntravel vibe?',
      subtitle: 'Pick all that feel like you. This powers your matches.',
      bottom: bottom,
      canContinue: selected.isNotEmpty,
      onNext: onNext,
      btnLabel: selected.isEmpty
          ? 'Pick at least one'
          : 'Continue with ${selected.length} selected',
      child: Wrap(
        spacing: 10, runSpacing: 10,
        children: _vibes.map((v) {
          final active = selected.contains(v.label);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle(v.label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: active
                    ? v.color.withOpacity(.15)
                    : Colors.white.withOpacity(.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? v.color.withOpacity(.50)
                      : Colors.white.withOpacity(.08),
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(v.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(v.label, style: TextStyle(
                    color: active ? _kText : _kMuted,
                    fontSize: 13, fontWeight: FontWeight.w600,
                  )),
                  if (active) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_rounded, color: v.color, size: 14),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 4: Travel Style ─────────────────────────────────────────────────────

class _StepStyle extends StatelessWidget {
  final String budget, pace, accomm;
  final double bottom;
  final ValueChanged<String> onBudget, onPace, onAccomm;
  final bool canContinue;
  final VoidCallback onNext;

  const _StepStyle({
    required this.budget, required this.pace, required this.accomm,
    required this.bottom, required this.onBudget, required this.onPace,
    required this.onAccomm, required this.canContinue, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      emoji: '🎒',
      title: 'Your travel\nstyle',
      subtitle: 'Helps us find people who are actually compatible.',
      bottom: bottom, canContinue: canContinue,
      onNext: onNext, btnLabel: 'Continue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChoiceGroup(
            label: 'Budget',
            options: const ['₹ Budget', '₹₹ Mid-range', '₹₹₹ Comfortable', '💎 Luxury'],
            selected: budget,
            onSelect: onBudget,
            color: _kGold,
          ),
          const SizedBox(height: 20),
          _ChoiceGroup(
            label: 'Travel Pace',
            options: const ['🐢 Slow & Easy', '⚡ Fast & Packed', '🎲 Spontaneous'],
            selected: pace,
            onSelect: onPace,
            color: _kTeal2,
          ),
          const SizedBox(height: 20),
          _ChoiceGroup(
            label: 'Accommodation',
            options: const ['🏨 Hotels', '🏠 Airbnb', '🛏 Hostels', '⛺ Camping'],
            selected: accomm,
            onSelect: onAccomm,
            color: _kTeal2,
          ),
        ],
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color color;

  const _ChoiceGroup({
    required this.label, required this.options,
    required this.selected, required this.onSelect, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(
          color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
          letterSpacing: .08,
        )),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: options.map((o) {
            final active = selected == o;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(o);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: active
                      ? color.withOpacity(.12)
                      : Colors.white.withOpacity(.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active
                        ? color.withOpacity(.45)
                        : Colors.white.withOpacity(.07),
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Text(o, style: TextStyle(
                  color: active ? _kText : _kMuted,
                  fontSize: 13, fontWeight: FontWeight.w600,
                )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Step 5: Bio + Launch ─────────────────────────────────────────────────────

class _StepBio extends StatelessWidget {
  final TextEditingController bioCtrl;
  final String name;
  final double bottom;
  final VoidCallback onNext;

  const _StepBio({
    required this.bioCtrl, required this.name,
    required this.bottom, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      emoji: '🚀',
      title: 'One last thing,\n${name.isNotEmpty ? name.split(' ').first : 'traveler'}',
      subtitle: 'Write a short bio. What kind of trip are you looking for?',
      bottom: bottom, canContinue: true,
      onNext: onNext, btnLabel: 'Launch my profile 🎉',
      btnGold: true,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: bioCtrl,
              maxLines: 5,
              style: const TextStyle(color: _kText, fontSize: 14, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'e.g. Solo traveler from Mumbai. Mountains & cafes. Looking for low-key adventure partners who don\'t overplan...',
                hintStyle: TextStyle(color: _kFaint, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Preview card teaser
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kTeal.withOpacity(.15)),
            ),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome_rounded, color: _kTeal2, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your profile card will go live on the Discover feed right after.',
                    style: TextStyle(color: _kMuted, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared shell ─────────────────────────────────────────────────────────────

class _StepShell extends StatelessWidget {
  final String emoji, title, subtitle, btnLabel;
  final double bottom;
  final bool canContinue;
  final bool btnGold;
  final VoidCallback onNext;
  final Widget child;

  const _StepShell({
    required this.emoji, required this.title, required this.subtitle,
    required this.btnLabel, required this.bottom, required this.canContinue,
    required this.onNext, required this.child, this.btnGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 14),

                // Title
                Text(title, style: const TextStyle(
                  color: _kText, fontSize: 30,
                  fontWeight: FontWeight.w800, letterSpacing: -.5, height: 1.15,
                )),
                const SizedBox(height: 8),

                // Subtitle
                Text(subtitle, style: const TextStyle(
                  color: _kMuted, fontSize: 14, height: 1.5,
                )),
                const SizedBox(height: 32),

                // Step content
                child,
              ],
            ),
          ),
        ),

        // CTA button
        Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottom),
          child: GestureDetector(
            onTap: canContinue ? onNext : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: canContinue
                    ? (btnGold
                    ? const LinearGradient(
                    colors: [_kGold, Color(0xFFE09620)])
                    : const LinearGradient(
                    colors: [_kTeal2, _kTeal]))
                    : null,
                color: canContinue ? null : Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(18),
                border: canContinue
                    ? null
                    : Border.all(color: Colors.white.withOpacity(.08)),
                boxShadow: canContinue ? [
                  BoxShadow(
                    color: (btnGold ? _kGold : _kTeal).withOpacity(.28),
                    blurRadius: 24, offset: const Offset(0, 10),
                  ),
                ] : [],
              ),
              child: Center(
                child: Text(btnLabel, style: TextStyle(
                  color: canContinue
                      ? (btnGold ? Colors.black : const Color(0xFF041818))
                      : _kFaint,
                  fontSize: 15, fontWeight: FontWeight.w800,
                )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared underline field ───────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final TextInputType? keyboardType;
  final VoidCallback onChanged;

  const _Field({
    required this.ctrl, required this.label, required this.hint,
    this.keyboardType, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(
          color: _kFaint, fontSize: 10,
          fontWeight: FontWeight.w800, letterSpacing: .08,
        )),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          onChanged: (_) => onChanged(),
          style: const TextStyle(color: _kText, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kFaint, fontSize: 16),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x18FFFFFF)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x18FFFFFF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _kTeal2, width: 1.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}