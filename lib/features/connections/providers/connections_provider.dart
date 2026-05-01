// lib/features/connections/providers/connections_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connection_model.dart';
import '../data/connections_repository.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  return ConnectionsRepository();
});

/// My accepted connections.
/// keepAlive: survives tab switches. 3-min TTL balances freshness vs. API calls.
final connectionsProvider = FutureProvider<List<ConnectionModel>>((ref) async {
  final link   = ref.keepAlive();
  Timer(const Duration(minutes: 3), link.close);
  final repo   = ref.read(connectionsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConnections(userId);
});

/// Pending requests I've received.
/// keepAlive: 2-min TTL — needs to feel live when someone sends a request.
final pendingRequestsProvider = FutureProvider<List<ConnectionModel>>((ref) async {
  final link   = ref.keepAlive();
  Timer(const Duration(minutes: 2), link.close);
  final repo   = ref.read(connectionsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getPendingRequests(userId);
});

class ConnectionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ConnectionsRepository _repo;
  final String _userId;
  final Ref _ref;

  ConnectionsNotifier(this._repo, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> sendRequest(String receiverId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.sendRequest(requesterId: _userId, receiverId: receiverId);
      state = const AsyncValue.data(null);
      // Bust pending cache so the sender's outgoing request shows immediately
      _ref.invalidate(pendingRequestsProvider);
      _ref.invalidate(connectionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> respond({
    required String connectionId,
    required bool accept,
  }) async {
    await _repo.respondToRequest(connectionId: connectionId, accept: accept);
    // Bust both caches so accept/decline reflects immediately
    _ref.invalidate(pendingRequestsProvider);
    _ref.invalidate(connectionsProvider);
  }
}

final connectionsNotifierProvider =
    StateNotifierProvider<ConnectionsNotifier, AsyncValue<void>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return ConnectionsNotifier(
    ref.watch(connectionsRepositoryProvider),
    userId,
    ref,
  );
});
