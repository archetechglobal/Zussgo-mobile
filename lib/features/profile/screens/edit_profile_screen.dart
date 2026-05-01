// lib/features/profile/screens/edit_profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/profile_provider.dart';
import '../../../features/profile/data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _bg      = Color(0xFF070E0F);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFFA8C4BF);
  static const _faint   = Color(0xFF6A8882);

  late final TextEditingController _nameCtrl;
  late final TextEditingController _baseCtrl;
  late final TextEditingController _bioCtrl;
  late List<String> _traits;

  bool _initialized = false;
  bool _saving      = false;
  File? _pendingAvatar;
  String? _existingAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _baseCtrl = TextEditingController();
    _bioCtrl  = TextEditingController();
    _traits   = [];
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

  void _initFromProfile(profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _nameCtrl.text       = profile.name ?? '';
    _baseCtrl.text       = profile.baseCity ?? '';
    _bioCtrl.text        = profile.bio ?? '';
    _traits              = List<String>.from(profile.vibes ?? []);
    _existingAvatarUrl   = profile.avatarUrl;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pendingAvatar = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final notifier = ref.read(myProfileProvider.notifier);
      final current  = ref.read(myProfileProvider).value;

      // Upload avatar if changed
      if (_pendingAvatar != null) {
        await notifier.uploadAvatar(_pendingAvatar!);
      }

      // Save text fields via upsert
      if (current != null) {
        final updated = current.copyWith(
          name:      _nameCtrl.text.trim(),
          baseCity:  _baseCtrl.text.trim(),
          bio:       _bioCtrl.text.trim(),
          vibes:     _traits,
        );
        await ref.read(profileRepositoryProvider).upsertProfile(updated);
        await notifier.refresh();
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
              const Text(
                'Add Trait',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _UnderlineField(
                controller: ctrl,
                label: '',
                hint: 'e.g. \uD83C\uDFD4 Mountains',
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
                    child: Text(
                      'Add',
                      style: TextStyle(
                          color: Color(0xFF041818),
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
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

  void _removeTrait(int index) =>
      setState(() => _traits.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final profileAsync = ref.watch(myProfileProvider);

    profileAsync.whenData((p) => _initFromProfile(p));

    final avatarUrl = _existingAvatarUrl;
    final name      = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'T';
    final initial   = name[0].toUpperCase();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // Sticky header
          Container(
            padding: EdgeInsets.fromLTRB(20, topInset + 10, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1516),
              border: Border(
                bottom:
                    BorderSide(color: Colors.white.withOpacity(.05)),
              ),
            ),
            child: Row(
              children: [
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
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Color(0xFF58DAD0), strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Done',
                          style: TextStyle(
                              color: _teal2,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(20, 20, 20, 32 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Avatar
                  const _SectionLabel('Photo'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: _pendingAvatar != null
                              ? Image.file(
                                  _pendingAvatar!,
                                  width: 90, height: 90,
                                  fit: BoxFit.cover,
                                )
                              : (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? Image.network(
                                      avatarUrl,
                                      width: 90, height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _AvatarFallbackSmall(
                                              initial: initial),
                                    )
                                  : _AvatarFallbackSmall(
                                      initial: initial),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1EC9B8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _bg, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white, size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  _UnderlineField(
                    controller: _nameCtrl,
                    label: 'Name',
                  ),
                  const SizedBox(height: 20),

                  // Home Base
                  _UnderlineField(
                    controller: _baseCtrl,
                    label: 'Home Base',
                    hint: 'City, Country',
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  _UnderlineField(
                    controller: _bioCtrl,
                    label: 'Bio',
                    hint: 'Tell fellow travelers about yourself...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Travel Traits
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

// ─── Avatar fallback (small) ──────────────────────────────────────────────────

class _AvatarFallbackSmall extends StatelessWidget {
  final String initial;
  const _AvatarFallbackSmall({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, height: 90,
      color: const Color(0xFF1EC9B8).withOpacity(.20),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFF58DAD0),
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          _SectionLabel(widget.label),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: const TextStyle(
              color: _text, fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: _faint, fontSize: 15),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(.10)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _teal2, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
            isDense: true,
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
          ...traits.asMap().entries.map((e) => GestureDetector(
            onLongPress: () => onRemove(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.value,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Icon(Icons.close_rounded,
                      size: 12,
                      color: Color(0xFF6A8882)),
                ],
              ),
            ),
          )),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _teal.withOpacity(.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _teal.withOpacity(.30)),
              ),
              child: const Text(
                '+ Add Trait',
                style: TextStyle(
                    color: _teal2,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
