import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  bool _requestSent = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _checkExistingRequest();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select(
            'id, full_name, display_name, avatar_url, bio, location, based_in, '
            'vibes, trip_count, buddy_count, rating, active_trip_id, '
            'trips:active_trip_id(id, name, start_date, end_date, looking_for)',
          )
          .eq('id', widget.userId)
          .single();
      if (mounted) {
        setState(() {
          _profile = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkExistingRequest() async {
    try {
      final me = _supabase.auth.currentUser?.id;
      if (me == null) return;
      final existing = await _supabase
          .from('connections')
          .select('id')
          .eq('sender_id', me)
          .eq('receiver_id', widget.userId)
          .maybeSingle();
      if (mounted && existing != null) {
        setState(() => _requestSent = true);
      }
    } catch (_) {}
  }

  Future<void> _sendConnectionRequest() async {
    if (_requestSent || _sending) return;
    final me = _supabase.auth.currentUser?.id;
    if (me == null) return;

    setState(() => _sending = true);

    final hasActiveTrip = _profile?['active_trip_id'] != null;

    try {
      await _supabase.from('connections').insert({
        'sender_id': me,
        'receiver_id': widget.userId,
        'status': 'pending',
        'type': hasActiveTrip ? 'trip_request' : 'general',
        if (hasActiveTrip) 'trip_id': _profile!['active_trip_id'],
      });
      if (mounted) {
        setState(() {
          _requestSent = true;
          _sending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasActiveTrip ? 'Trip request sent!' : 'Connection request sent!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Profile not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_error != null) ...
                [const SizedBox(height: 8), Text(_error!, style: const TextStyle(color: Colors.grey))],
            ],
          ),
        ),
      );
    }

    final p = _profile!;
    final name = (p['full_name'] ?? p['display_name'] ?? 'User') as String;
    final bio = (p['bio'] ?? '') as String;
    final avatarUrl = p['avatar_url'] as String?;
    final basedIn = (p['location'] ?? p['based_in'] ?? '') as String;
    final vibes = (p['vibes'] as List?)?.cast<String>() ?? <String>[];
    final tripCount = p['trip_count'] as int? ?? 0;
    final buddyCount = p['buddy_count'] as int? ?? 0;
    final rating = (p['rating'] as num?)?.toDouble() ?? 0.0;
    final activeTrip = p['trips'] as Map<String, dynamic>?;
    final hasActiveTrip = activeTrip != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // ── App bar with avatar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFF58DAD0),
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    if (basedIn.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '📍 $basedIn',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(label: 'Trips', value: '$tripCount'),
                      _StatChip(label: 'Buddies', value: '$buddyCount'),
                      _StatChip(
                          label: 'Rating',
                          value: rating > 0 ? rating.toStringAsFixed(1) : '—'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Bio ───────────────────────────────────────────────────
                  if (bio.isNotEmpty) ...[  
                    const _SectionLabel('About'),
                    const SizedBox(height: 6),
                    Text(
                      bio,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Vibes ─────────────────────────────────────────────────
                  if (vibes.isNotEmpty) ...[  
                    const _SectionLabel('Travel Vibes'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: vibes
                          .map((v) => _VibePill(label: v))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Active trip card (optional — shown only when exists) ──
                  if (hasActiveTrip) ...[  
                    const _SectionLabel('Active Trip'),
                    const SizedBox(height: 10),
                    _ActiveTripCard(trip: activeTrip!),
                    const SizedBox(height: 20),
                  ],

                  // ── No trip notice ────────────────────────────────────────
                  if (!hasActiveTrip)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white12, width: 1),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.explore_outlined,
                              color: Colors.white38, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No active trip right now — but open to planning one!',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ── Connect button — ALWAYS VISIBLE ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed:
                          (_requestSent || _sending) ? null : _sendConnectionRequest,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              _requestSent
                                  ? Icons.check_circle_outline
                                  : (hasActiveTrip
                                      ? Icons.luggage_outlined
                                      : Icons.person_add_outlined),
                            ),
                      label: Text(
                        _requestSent
                            ? 'Request Sent'
                            : (hasActiveTrip
                                ? 'Request to Join Trip'
                                : 'Connect with $name'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _requestSent
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFF58DAD0),
                        foregroundColor:
                            _requestSent ? Colors.white54 : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _VibePill extends StatelessWidget {
  final String label;
  const _VibePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF58DAD0).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF58DAD0).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Color(0xFF58DAD0),
            fontSize: 13,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const _ActiveTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final tripName = trip['name'] ?? 'Upcoming Trip';
    final startDate = trip['start_date'] ?? '';
    final endDate = trip['end_date'] ?? '';
    final lookingFor = trip['looking_for'] ?? '';
    final dateRange =
        (startDate.isNotEmpty && endDate.isNotEmpty) ? '$startDate – $endDate' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF58DAD0).withOpacity(0.15),
            const Color(0xFF1C1C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF58DAD0).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage_outlined,
                  color: Color(0xFF58DAD0), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tripName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          if (dateRange.isNotEmpty) ...[  
            const SizedBox(height: 6),
            Text(
              dateRange,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 13),
            ),
          ],
          if (lookingFor.isNotEmpty) ...[  
            const SizedBox(height: 4),
            Text(
              lookingFor,
              style: const TextStyle(
                  color: Color(0xFF58DAD0), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
