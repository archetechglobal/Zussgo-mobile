// lib/features/connections/providers/connections_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/connections_repository.dart';
import '../models/connection_model.dart';

final connectionsRepositoryProvider =
Provider((_) => ConnectionsRepository());

// ── Accepted connections (chat list source) ────────────────────────────────────
final myConnectionsProvider =
FutureProvider<List<ConnectionModel>>((ref) async {
  return ref.read(connectionsRepositoryProvider).fetchMyConnections();
});

// ── Pending received requests ──────────────────────────────────────────────────
final pendingRequestsProvider =
FutureProvider<List<ConnectionModel>>((ref) async {
  return ref.read(connectionsRepositoryProvider).fetchPendingReceived();
});

// ── Send request notifier ──────────────────────────────────────────────────────
class SendRequestNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> send({
    required String receiverId,
    required String tripId,
    required String message,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(connectionsRepositoryProvider).sendRequest(
          receiverId: receiverId,
          tripId: tripId,
          message: message,
        ));
  }
}

final sendRequestProvider =
AsyncNotifierProvider<SendRequestNotifier, void>(SendRequestNotifier.new);

// ── Accept/decline ─────────────────────────────────────────────────────────────
final acceptRequestProvider = FutureProvider.family<void, String>((ref, id) async {
  await ref.read(connectionsRepositoryProvider).acceptRequest(id);
  ref.invalidate(pendingRequestsProvider);
  ref.invalidate(myConnectionsProvider);
});

final declineRequestProvider = FutureProvider.family<void, String>((ref, id) async {
  await ref.read(connectionsRepositoryProvider).declineRequest(id);
  ref.invalidate(pendingRequestsProvider);
});