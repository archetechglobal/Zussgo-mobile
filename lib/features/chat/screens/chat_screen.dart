// lib/features/chat/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/ai_spark_chip.dart';
import '../widgets/itinerary_tray.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggest_place_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String peerId;      // ← added
  final String peerName;
  final String tripLabel;

  const ChatScreen({
    super.key,
    this.peerId = 'rahul',  // ← added
    this.peerName = 'Rahul',
    this.tripLabel = 'Goa Beach Crew',
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showItinerary = false;

  static const _bg    = Color(0xFF070E0F);
  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);

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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String val) {
    if (detectPlaceIntent(val)) {
      final suggestion = suggestCardFromText(val);
      ref.read(aiSparkProvider.notifier).state = suggestion;
    } else {
      ref.read(aiSparkProvider.notifier).state = null;
    }
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(messagesProvider.notifier).send(text);
    _controller.clear();
    ref.read(aiSparkProvider.notifier).state = null;
    _scrollToBottom();
  }

  void _sendPlanCard(PlanCardData card) {
    ref.read(messagesProvider.notifier).addPlanCard(card);
    ref.read(aiSparkProvider.notifier).state = null;
    _scrollToBottom();
  }

  void _addToItinerary(String messageId, PlanCardData card) {
    ref.read(messagesProvider.notifier).markAdded(messageId);
    ref.read(itineraryProvider.notifier).addFromCard(card);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openSuggestSheet({PlanCardData? prefilled}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuggestPlaceSheet(
        prefilled: prefilled,
        onSend: _sendPlanCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final messages    = ref.watch(messagesProvider);
    final aiSpark     = ref.watch(aiSparkProvider);
    final itinerary   = ref.watch(itineraryProvider);

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.0,
            colors: [Color(0x181EC9B8), Colors.transparent],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: topInset),

            _ChatAppBar(
              peerName: widget.peerName,
              tripLabel: widget.tripLabel,
              onBack: () => context.go('/chat'),   // ← goes back to list
              onItineraryTap: () =>
                  setState(() => _showItinerary = !_showItinerary),
              itineraryCount: itinerary.length,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: _showItinerary
                  ? ItineraryTray(
                items: itinerary,
                onExpand: () {},
              )
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  return MessageBubble(
                    message: msg,
                    onAddToItinerary: msg.planCard != null &&
                        !msg.planCard!.addedToItinerary
                        ? () => _addToItinerary(msg.id, msg.planCard!)
                        : null,
                  );
                },
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: aiSpark != null
                  ? AiSparkChip(
                suggestion: aiSpark,
                onPreview: () => _openSuggestSheet(prefilled: aiSpark),
                onDismiss: () =>
                ref.read(aiSparkProvider.notifier).state = null,
              )
                  : const SizedBox.shrink(),
            ),

            _InputBar(
              controller: _controller,
              onChanged: _onTextChanged,
              onSend: _sendText,
              onPlustap: () => _openSuggestSheet(),
              bottomInset: bottomInset,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  final String peerName;
  final String tripLabel;
  final VoidCallback onBack;
  final VoidCallback onItineraryTap;
  final int itineraryCount;

  const _ChatAppBar({
    required this.peerName,
    required this.tripLabel,
    required this.onBack,
    required this.onItineraryTap,
    required this.itineraryCount,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF58DAD0), size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('R',
                  style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peerName,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tripLabel,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onItineraryTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _teal.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _teal.withOpacity(.2)),
              ),
              child: Row(
                children: [
                  const Text('🗓', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  const Text(
                    'Plan',
                    style: TextStyle(
                      color: _teal2,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (itineraryCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$itineraryCount',
                        style: const TextStyle(
                          color: Color(0xFF041818),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onPlustap;
  final double bottomInset;

  const _InputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.onPlustap,
    required this.bottomInset,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1516),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(.05)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onPlustap,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF6A8882), size: 20),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: null,
                style: const TextStyle(color: Color(0xFFEDF7F4), fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Color(0xFF6A8882), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Color(0xFF041818),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}