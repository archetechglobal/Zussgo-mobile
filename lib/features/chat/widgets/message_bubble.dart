// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'plan_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAddToItinerary;

  const MessageBubble({
    super.key,
    required this.message,
    this.onAddToItinerary,
  });

  static const _bg     = Color(0xFF081314);
  static const _teal   = Color(0xFF1EC9B8);
  static const _teal2  = Color(0xFF58DAD0);
  static const _text   = Color(0xFFEDF7F4);
  static const _muted  = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _Avatar(initial: 'R', color: const Color(0xFF58DAD0)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.planCard &&
                    message.planCard != null)
                  PlanCard(
                    data: message.planCard!,
                    isMe: isMe,
                    onAddToItinerary: onAddToItinerary,
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.68,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? _teal.withOpacity(.18)
                          : Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      border: Border.all(
                        color: isMe
                            ? _teal2.withOpacity(.18)
                            : Colors.white.withOpacity(.06),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  final Color color;
  const _Avatar({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(.25),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}