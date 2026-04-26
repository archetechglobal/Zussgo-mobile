import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connection_model.dart';
import '../data/connections_repository.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  return ConnectionsRepository();
});

final connectionsProvider = FutureProvider<List<ConnectionModel>>((ref) async {
  final repo   = ref.watch(connectionsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConnections(userId);
});

final pendingRequestsProvider = FutureProvider<List<ConnectionModel>>((ref) async {
  final repo   = ref.watch(connectionsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getPendingRequests(userId);
});

class ConnectionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ConnectionsRepository _repo;
  final String _userId;

  ConnectionsNotifier(this._repo, this._userId)
      : super(const AsyncValue.data(null));

  Future<void> sendRequest(String receiverId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.sendRequest(requesterId: _userId, receiverId: receiverId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> respond({required String connectionId, required bool accept}) async {
    await _repo.respondToRequest(connectionId: connectionId, accept: accept);
  }
}

final connectionsNotifierProvider =
StateNotifierProvider<ConnectionsNotifier, AsyncValue<void>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return ConnectionsNotifier(ref.watch(connectionsRepositoryProvider), userId);
});