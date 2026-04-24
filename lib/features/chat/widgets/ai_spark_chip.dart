// lib/features/chat/widgets/ai_spark_chip.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class AiSparkChip extends StatelessWidget {
  final PlanCardData suggestion;
  final VoidCallback onPreview;
  final VoidCallback onDismiss;

  const AiSparkChip({
    super.key,
    required this.suggestion,
    required this.onPreview,
    required this.onDismiss,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);
  static const _text  = Color(0xFFEDF7F4);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI spark icon
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1EC9B8), Color(0xFF58DAD0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 14, color: Color(0xFF041818))),
            ),
          ),
          const SizedBox(width: 10),

          // Place name + suggestion
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Spark  ',
                      style: TextStyle(
                        color: _teal2,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Place detected',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${suggestion.emoji} ${suggestion.placeName}',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Preview button
          GestureDetector(
            onTap: onPreview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Color(0xFF041818),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dismiss
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF6A8882),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}