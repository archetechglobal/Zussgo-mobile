// lib/features/profile/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _bg      = Color(0xFF070E0F);
  static const _surface = Color(0xFF0D1819);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFFA8C4BF);
  static const _faint   = Color(0xFF6A8882);

  // Mock: existing photo + one empty slot
  bool _hasPhoto = true;

  final _nameCtrl     = TextEditingController(text: 'Aryan');
  final _baseCtrl     = TextEditingController(text: 'Mumbai, India');
  final _bioCtrl      = TextEditingController(
    text: 'Designer by day, avoiding reality by weekend. Always looking for the best local coffee and hidden dive spots.',
  );

  final List<String> _traits = [
    '🌊 Beach Bum',
    '🌙 Night Owl',
    '🎒 Hostels',
    '🇮🇳 Hindi',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _baseCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _addTrait() async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF0D1819),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add Trait', style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 16),
              _UnderlineField(
                controller: ctrl,
                label: '',
                hint: 'e.g. 🏔 Mountains',
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    setState(() => _traits.add(ctrl.text.trim()));
                  }
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    color: _teal2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Add', style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 16, fontWeight: FontWeight.w800,
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeTrait(int index) {
    setState(() => _traits.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Sticky header ───────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, topInset + 10, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1516),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(.05)),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _text, size: 18,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Edit Profile', style: TextStyle(
                      color: _text, fontSize: 16, fontWeight: FontWeight.w700,
                    )),
                  ),
                ),
                // Done button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(
                    color: _teal2, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                ),
              ],
            ),
          ),

          // ── Scrollable form body ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 32 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Photos ─────────────────────────────────────────────
                  const _SectionLabel('Photos'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Existing photo
                        if (_hasPhoto) ...[
                          _PhotoBox(
                            imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
                            onDelete: () => setState(() => _hasPhoto = false),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Add photo slot
                        _AddPhotoBox(onTap: () {}),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Name ───────────────────────────────────────────────
                  _UnderlineField(
                    controller: _nameCtrl,
                    label: 'Name',
                  ),
                  const SizedBox(height: 20),

                  // ── Home Base ──────────────────────────────────────────
                  _UnderlineField(
                    controller: _baseCtrl,
                    label: 'Home Base',
                  ),
                  const SizedBox(height: 20),

                  // ── Bio ────────────────────────────────────────────────
                  _UnderlineField(
                    controller: _bioCtrl,
                    label: 'Bio',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // ── Travel Traits & Vibes ──────────────────────────────
                  const _SectionLabel('Travel Traits & Vibes'),
                  const SizedBox(height: 12),
                  _TraitsBox(
                    traits: _traits,
                    onRemove: _removeTrait,
                    onAdd: _addTrait,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF6A8882),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: .05,
      ),
    );
  }
}

// ─── Photo box (existing) ─────────────────────────────────────────────────────

class _PhotoBox extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDelete;
  const _PhotoBox({required this.imageUrl, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: 100, height: 120, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100, height: 120,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),
          // Delete badge
          Positioned(
            top: -6, right: -6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1516),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(.20)),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add photo box (empty slot) ───────────────────────────────────────────────

class _AddPhotoBox extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoBox({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(.20),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded,
              color: Color(0xFFA8C4BF), size: 24),
        ),
      ),
    );
  }
}

// ─── Underline input field ────────────────────────────────────────────────────

class _UnderlineField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  const _UnderlineField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  State<_UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<_UnderlineField> {
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _faint = Color(0xFF6A8882);

  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          _SectionLabel(widget.label),
          const SizedBox(height: 4),
        ],
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            style: const TextStyle(
              color: _text, fontSize: 15, height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: _faint, fontSize: 15),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(.10),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _teal2, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Traits box ───────────────────────────────────────────────────────────────

class _TraitsBox extends StatelessWidget {
  final List<String> traits;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  const _TraitsBox({
    required this.traits,
    required this.onRemove,
    required this.onAdd,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: [
          // Existing traits with long-press to remove
          ...traits.asMap().entries.map((e) => GestureDetector(
            onLongPress: () => onRemove(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                e.value,
                style: const TextStyle(
                  color: _text, fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )),

          // "+ Add Trait" chip
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _teal.withOpacity(.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _teal.withOpacity(.30),
                  // dashed not natively supported — solid subtle border
                ),
              ),
              child: const Text(
                '+ Add Trait',
                style: TextStyle(
                  color: _teal2, fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}