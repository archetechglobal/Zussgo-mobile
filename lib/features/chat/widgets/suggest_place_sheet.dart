// lib/features/chat/widgets/suggest_place_sheet.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class SuggestPlaceSheet extends StatefulWidget {
  final PlanCardData? prefilled; // from AI Spark
  final Function(PlanCardData) onSend;

  const SuggestPlaceSheet({
    super.key,
    this.prefilled,
    required this.onSend,
  });

  @override
  State<SuggestPlaceSheet> createState() => _SuggestPlaceSheetState();
}

class _SuggestPlaceSheetState extends State<SuggestPlaceSheet> {
  late final TextEditingController _placeController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  // Mock search results
  final List<Map<String, String>> _mockResults = [
    {'name': 'Curlies Beach Shack', 'cat': 'Bar & Café · Anjuna, Goa', 'emoji': '🍹'},
    {'name': 'Baga Beach', 'cat': 'Beach · North Goa', 'emoji': '🏖'},
    {'name': 'Artjuna Café', 'cat': 'Café · Anjuna, Goa', 'emoji': '☕'},
    {'name': 'Anjuna Flea Market', 'cat': 'Market · Anjuna, Goa', 'emoji': '🛍'},
    {'name': 'Key Monastery', 'cat': 'Monastery · Spiti Valley', 'emoji': '🏔'},
  ];

  List<Map<String, String>> _filtered = [];
  Map<String, String>? _selected;

  static const _bg    = Color(0xFF070E0F);
  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);

  @override
  void initState() {
    super.initState();
    _placeController = TextEditingController(
        text: widget.prefilled?.placeName ?? '');
    _dateController = TextEditingController(
        text: widget.prefilled?.date ?? 'May 12');
    _timeController = TextEditingController(
        text: widget.prefilled?.time ?? '5:30 PM');

    if (widget.prefilled != null) {
      _selected = {
        'name': widget.prefilled!.placeName,
        'cat': widget.prefilled!.category,
        'emoji': widget.prefilled!.emoji,
      };
    }
    _filtered = _mockResults;
  }

  @override
  void dispose() {
    _placeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _selected = null;
      _filtered = _mockResults
          .where((r) => r['name']!.toLowerCase().contains(val.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0C1819),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Suggest a Place',
            style: TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Search field
          _Field(
            controller: _placeController,
            hint: 'Search place name...',
            icon: Icons.search_rounded,
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 8),

          // Search results
          if (_selected == null && _filtered.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(.06)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.white.withOpacity(.05),
                ),
                itemBuilder: (_, i) {
                  final r = _filtered[i];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selected = r;
                      _placeController.text = r['name']!;
                      _filtered = [];
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Text(r['emoji']!,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['name']!,
                                    style: const TextStyle(
                                        color: _text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text(r['cat']!,
                                    style: const TextStyle(
                                        color: _faint, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_selected != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _teal.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _teal.withOpacity(.2)),
              ),
              child: Row(
                children: [
                  Text(_selected!['emoji']!,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selected!['name']!,
                          style: const TextStyle(
                              color: _text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Text(_selected!['cat']!,
                          style: const TextStyle(color: _muted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Date & Time row
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: _dateController,
                  hint: 'Date',
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  controller: _timeController,
                  hint: 'Time (optional)',
                  icon: Icons.access_time_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Send button
          GestureDetector(
            onTap: () {
              final place = _selected ??
                  {'name': _placeController.text, 'cat': '', 'emoji': '📍'};
              widget.onSend(PlanCardData(
                placeName: place['name']!,
                category: place['cat']!,
                date: _dateController.text,
                time: _timeController.text,
                emoji: place['emoji']!,
              ));
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Send to Chat as Plan',
                  style: TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFFEDF7F4), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFF6A8882), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF6A8882), size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1EC9B8), width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}