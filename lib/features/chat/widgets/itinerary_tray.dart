// lib/features/chat/widgets/itinerary_tray.dart

import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';

class ItineraryTray extends StatelessWidget {
  final List<ItineraryItem> items;
  final VoidCallback onExpand;

  const ItineraryTray({
    super.key,
    required this.items,
    required this.onExpand,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    final preview = items.take(2).toList();

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF091516),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🗓', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Shared Itinerary',
                    style: TextStyle(
                      color: _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'View all →',
                  style: TextStyle(
                    color: _teal2,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF1A2E30), height: 1),
              const SizedBox(height: 10),
              ...preview.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: const TextStyle(color: _faint, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
              if (items.length > 2)
                Text(
                  '+${items.length - 2} more plans',
                  style: const TextStyle(color: _faint, fontSize: 11),
                ),
            ],
          ],
        ),
      ),
    );
  }
}