// lib/features/chat/widgets/plan_card.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class PlanCard extends StatelessWidget {
  final PlanCardData data;
  final bool isMe;
  final VoidCallback? onAddToItinerary;

  const PlanCard({
    super.key,
    required this.data,
    required this.isMe,
    this.onAddToItinerary,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1F22),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        border: Border.all(color: _teal.withOpacity(.18)),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _teal.withOpacity(.2)),
                ),
                child: Center(
                  child: Text(data.emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.placeName,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.category,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Date + Time chips
          Row(
            children: [
              _Chip(label: '📅 ${data.date}'),
              const SizedBox(width: 6),
              _Chip(label: '⏰ ${data.time}'),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          if (data.addedToItinerary)
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: _teal.withOpacity(.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _teal.withOpacity(.2)),
              ),
              child: const Center(
                child: Text(
                  '✓ Added to Itinerary',
                  style: TextStyle(
                    color: _teal2,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onAddToItinerary,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withOpacity(.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Add to Itinerary',
                          style: TextStyle(
                            color: Color(0xFF041818),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {}, // suggest edit — hook in later
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: const Center(
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: _faint,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA8C4BF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}