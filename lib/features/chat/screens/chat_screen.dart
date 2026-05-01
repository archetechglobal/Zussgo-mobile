// lib/features/chat/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/ai_spark_chip.dart';
import '../widgets/itinerary_tray.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggest_place_sheet.dart';
import '../../trips/screens/active_trip_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;
  final String tripLabel;

  const ChatScreen({
    super.key,
    this.peerId    = '',
    this.peerName  = 'Traveller',
    this.tripLabel = 'Trip',
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller       = TextEditingController();
  final _scrollController = ScrollController();
  bool  _showItinerary    = false;

  static const _bg    = Color(0xFF070E0F);
  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);

  // Build a local UI ChatMessage from a live MessageModel
  ChatMessage _toLocal(dynamic m, String myId) {
    return ChatMessage(
      id:        m.id as String,
      text:      m.content as String,
      isMe:      (m.senderId as String) == myId,
      timestamp: m.createdAt as DateTime,
    );
  }

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

  // chatNotifierProvider is a StateNotifierProvider — read the notifier directly
  void _sendText(String connectionId) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatNotifierProvider(connectionId).notifier).send(text);
    _controller.clear();
    ref.read(aiSparkProvider.notifier).state = null;
    _scrollToBottom();
  }

  void _sendPlanCard(String connectionId, PlanCardData card) {
    ref.read(chatNotifierProvider(connectionId).notifier).send(
      '📍 ${card.placeName} • ${card.category} • ${card.date} ${card.time}',
    );
    ref.read(aiSparkProvider.notifier).state = null;
    _scrollToBottom();
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

  void _startTrip() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => ActiveTripScreen(
          tripName:        widget.tripLabel,
          partnerName:     widget.peerName,
          partnerImageUrl: '',
          startTime:       _formattedNow(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _formattedNow() {
    final now  = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0 ? 12 : now.hour;
    final min  = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$min $ampm';
  }

  void _openSuggestSheet(String connectionId, {PlanCardData? prefilled}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuggestPlaceSheet(
        prefilled: prefilled,
        onSend: (card) => _sendPlanCard(connectionId, card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final myId        = Supabase.instance.client.auth.currentUser?.id ?? '';

    final aiSpark   = ref.watch(aiSparkProvider);
    final itinerary = ref.watch(itineraryProvider);

    // Resolve connection id first
    final connAsync = ref.watch(connectionIdProvider(widget.peerId));

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: connAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1EC9B8), strokeWidth: 2,
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFF3D5C58), size: 48),
              const SizedBox(height: 12),
              Text(
                'Could not connect',
                style: TextStyle(color: _faint, fontSize: 14),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    ref.refresh(connectionIdProvider(widget.peerId)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _teal.withOpacity(.3)),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Color(0xFF58DAD0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (connectionId) {
          if (connectionId == null) {
            return _NoConnectionView(
              peerName: widget.peerName,
              onBack: () => context.go('/chat'),
            );
          }

          final msgsAsync =
              ref.watch(messagesStreamProvider(connectionId));

          return Container(
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
                  peerName:       widget.peerName,
                  tripLabel:      widget.tripLabel,
                  onBack:         () => context.go('/chat'),
                  onItineraryTap: () =>
                      setState(() => _showItinerary = !_showItinerary),
                  itineraryCount: itinerary.length,
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: _showItinerary
                      ? ItineraryTray(items: itinerary, onExpand: () {})
                      : const SizedBox.shrink(),
                ),

                _StartTripBanner(
                  peerName:  widget.peerName,
                  tripLabel: widget.tripLabel,
                  onStart:   _startTrip,
                ),

                // Message list
                Expanded(
                  child: msgsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1EC9B8), strokeWidth: 2,
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Could not load messages',
                        style: TextStyle(
                            color: _faint, fontSize: 13),
                      ),
                    ),
                    data: (liveMessages) {
                      WidgetsBinding.instance
                          .addPostFrameCallback(
                              (_) => _scrollToBottom());

                      if (liveMessages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👋',
                                  style:
                                      TextStyle(fontSize: 40)),
                              const SizedBox(height: 12),
                              Text(
                                'Say hi to ${widget.peerName}!',
                                style: TextStyle(
                                    color: _faint, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      final uiMessages = liveMessages
                          .map((m) => _toLocal(m, myId))
                          .toList();

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                            16, 8, 16, 12),
                        itemCount: uiMessages.length,
                        itemBuilder: (_, i) => MessageBubble(
                          message: uiMessages[i],
                          onAddToItinerary: null,
                        ),
                      );
                    },
                  ),
                ),

                // AI spark chip
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: aiSpark != null
                      ? AiSparkChip(
                          suggestion: aiSpark,
                          onPreview: () => _openSuggestSheet(
                              connectionId,
                              prefilled: aiSpark),
                          onDismiss: () => ref
                              .read(aiSparkProvider.notifier)
                              .state = null,
                        )
                      : const SizedBox.shrink(),
                ),

                // Input bar
                _InputBar(
                  controller:  _controller,
                  onChanged:   _onTextChanged,
                  onSend:      () => _sendText(connectionId),
                  onPlustap:   () =>
                      _openSuggestSheet(connectionId),
                  bottomInset: bottomInset,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── No connection placeholder ────────────────────────────────────────────────

class _NoConnectionView extends StatelessWidget {
  final String peerName;
  final VoidCallback onBack;
  const _NoConnectionView(
      {required this.peerName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF3D5C58), size: 48),
            const SizedBox(height: 16),
            Text(
              'No accepted connection\nwith $peerName yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF6A8882), fontSize: 14),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1EC9B8).withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          const Color(0xFF1EC9B8).withOpacity(.3)),
                ),
                child: const Text(
                  'Back to Chats',
                  style: TextStyle(
                    color: Color(0xFF58DAD0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                border: Border.all(
                    color: Colors.white.withOpacity(.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF58DAD0),
                size: 15,
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
            child: Center(
              child: Text(
                peerName.isNotEmpty ? peerName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF041818),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
                  style:
                      const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onItineraryTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
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
  final ValueChanged<String>  onChanged;
  final VoidCallback          onSend;
  final VoidCallback          onPlustap;
  final double                bottomInset;

  const _InputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.onPlustap,
    required this.bottomInset,
  });

  static const _teal = Color(0xFF1EC9B8);

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
                border: Border.all(
                    color: Colors.white.withOpacity(.08)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF6A8882),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(.08)),
              ),
              child: TextField(
                controller: controller,
                onChanged:  onChanged,
                onSubmitted: (_) => onSend(),
                maxLines: null,
                style: const TextStyle(
                  color: Color(0xFFEDF7F4),
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                      color: Color(0xFF6A8882), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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

// ─── Start Trip Banner ────────────────────────────────────────────────────────

class _StartTripBanner extends StatefulWidget {
  final String peerName;
  final String tripLabel;
  final VoidCallback onStart;

  const _StartTripBanner({
    required this.peerName,
    required this.tripLabel,
    required this.onStart,
  });

  @override
  State<_StartTripBanner> createState() => _StartTripBannerState();
}

class _StartTripBannerState extends State<_StartTripBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double>   _glow;

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _faint = Color(0xFF6A8882);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween(begin: 0.20, end: 0.45).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_teal.withOpacity(.12), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _teal.withOpacity(_glow.value)),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(_glow.value * 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              SizedBox(
                width: 14, height: 14,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _teal.withOpacity(_glow.value * 0.6),
                      ),
                    ),
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: _teal2,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tripLabel,
                      style: const TextStyle(
                        color: _teal2,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .02,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Plans locked in? Start live tracking.',
                      style: TextStyle(color: _faint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _teal.withOpacity(.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Start Trip',
                    style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
}
