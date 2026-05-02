// lib/features/match/widgets/match_score_badge.dart
//
// Overlay badge shown on traveler cards in the Discover grid.
// Displays score + label. Handles loading, null, and error states gracefully.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/match_score_service.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/models/trip_model.dart';

class MatchScoreBadge extends ConsumerStatefulWidget {
  final ProfileModel viewer;
  final TripModel trip;

  const MatchScoreBadge({
    super.key,
    required this.viewer,
    required this.trip,
  });

  @override
  ConsumerState<MatchScoreBadge> createState() => _MatchScoreBadgeState();
}

class _MatchScoreBadgeState extends ConsumerState<MatchScoreBadge> {
  MatchScoreResult? _result;
  bool _loading = true;

  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);
  static const dark  = Color(0xFF041818);

  @override
  void initState() {
    super.initState();
    _fetchScore();
  }

  Future<void> _fetchScore() async {
    final service = ref.read(matchScoreServiceProvider);
    final result = await service.getScore(
      viewer: widget.viewer,
      trip:   widget.trip,
    );
    if (mounted) {
      setState(() {
        _result  = result;
        _loading = false;
      });
    }
  }

  Color get _badgeColor {
    final s = _result?.score ?? 0;
    if (s >= 85) return teal;
    if (s >= 70) return teal2;
    return gold;
  }

  @override
  Widget build(BuildContext context) {
    // While loading — show a subtle shimmer pill
    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                color: teal2.withOpacity(.6),
                strokeWidth: 1.5,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Scoring…',
              style: TextStyle(
                color: Colors.white.withOpacity(.45),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // No result — hide badge entirely
    if (_result == null) return const SizedBox.shrink();

    final r = _result!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark.withOpacity(.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _badgeColor.withOpacity(.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✦',
            style: TextStyle(
              color: _badgeColor,
              fontSize: 8,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${r.score}% · ${r.label}',
            style: TextStyle(
              color: _badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score detail bottom sheet — shown when user taps the badge
// ---------------------------------------------------------------------------

class MatchScoreSheet extends StatelessWidget {
  final MatchScoreResult result;
  final String candidateName;

  const MatchScoreSheet({
    super.key,
    required this.result,
    required this.candidateName,
  });

  static const bg2   = Color(0xFF0D1A1C);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);
  static const dark  = Color(0xFF041818);

  Color get _scoreColor {
    if (result.score >= 85) return teal;
    if (result.score >= 70) return teal2;
    return gold;
  }

  static void show(BuildContext context, MatchScoreResult result, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MatchScoreSheet(result: result, candidateName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 24),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          // Score ring area
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _scoreColor, width: 3),
              color: _scoreColor.withOpacity(.08),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${result.score}%',
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.label,
            style: const TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'with $candidateName',
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          // Reasons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHY YOU MATCH',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                ...result.reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✦ ', style: TextStyle(color: _scoreColor, fontSize: 11)),
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(
                            color: text,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (result.dealbreaker != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'HEADS UP',
                    style: TextStyle(
                      color: Color(0xFFFFB3C1),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠ ', style: TextStyle(color: Color(0xFFFFB3C1), fontSize: 11)),
                      Expanded(
                        child: Text(
                          result.dealbreaker!,
                          style: const TextStyle(
                            color: Color(0xFFFFB3C1),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: bottom + 32),
        ],
      ),
    );
  }
}
