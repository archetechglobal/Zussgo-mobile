// lib/features/match/screens/trip_detail_screen.dart
//
// Deep-link landing screen when a user taps a match notification.
// Fetches the trip by ID and shows the full trip card + match score.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Map<String, dynamic>? _trip;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    if (widget.tripId.isEmpty) {
      setState(() { _loading = false; _error = 'No trip ID provided.'; });
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('trips')
          .select('*, creator:profiles!trips_user_id_fkey(id, name, avatar_url, bio)')
          .eq('id', widget.tripId)
          .maybeSingle();

      setState(() {
        _trip    = data;
        _loading = false;
        if (data == null) _error = 'Trip not found.';
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Could not load trip.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Always go back to Discover tab
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/match', extra: 'discover');
            }
          },
        ),
        title: const Text('Match Found'),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _trip == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error ?? 'Trip unavailable',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.go('/match', extra: 'discover'),
              child: const Text('Browse Discover'),
            ),
          ],
        ),
      );
    }

    final trip    = _trip!;
    final creator = trip['creator'] as Map<String, dynamic>? ?? {};
    final avatarUrl = creator['avatar_url'] as String? ?? '';
    final creatorName = creator['name'] as String? ?? 'Traveler';
    final destination = trip['destination'] as String? ?? '';
    final vibe        = trip['vibe'] as String? ?? '';
    final budget      = trip['budget'] as String? ?? '';
    final bio         = creator['bio'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Match banner ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('✈️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$creatorName is heading to $destination',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Creator card ──────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(creatorName.isNotEmpty ? creatorName[0] : '?',
                        style: const TextStyle(fontSize: 24))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(creatorName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (bio.isNotEmpty)
                      Text(bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Trip details ──────────────────────────────────────────────────
          _DetailRow(icon: Icons.location_on_rounded,  label: 'Destination', value: destination),
          _DetailRow(icon: Icons.mood_rounded,          label: 'Vibe',        value: vibe),
          _DetailRow(icon: Icons.attach_money_rounded,  label: 'Budget',      value: budget),

          const SizedBox(height: 32),

          // ── CTA ───────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/match', extra: 'discover'),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('View in Discover'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Text('$label  ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
