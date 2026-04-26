import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/connection_model.dart';

class ConnectionsRepository {
  Future<void> sendRequest({
    required String requesterId,
    required String receiverId,
  }) async {
    await supabase.from(AppConstants.connectionsTable).insert({
      'requester_id': requesterId,
      'receiver_id':  receiverId,
      'status':       'pending',
    });
  }

  Future<void> respondToRequest({
    required String connectionId,
    required bool accept,
  }) async {
    await supabase
        .from(AppConstants.connectionsTable)
        .update({'status': accept ? 'accepted' : 'declined'})
        .eq('id', connectionId);
  }

  Future<List<ConnectionModel>> getConnections(String userId) async {
    final data = await supabase
        .from(AppConstants.connectionsTable)
        .select()
        .or('requester_id.eq.$userId,receiver_id.eq.$userId')
        .eq('status', 'accepted');
    return (data as List).map((e) => ConnectionModel.fromJson(e)).toList();
  }

  Future<List<ConnectionModel>> getPendingRequests(String userId) async {
    final data = await supabase
        .from(AppConstants.connectionsTable)
        .select()
        .eq('receiver_id', userId)
        .eq('status', 'pending');
    return (data as List).map((e) => ConnectionModel.fromJson(e)).toList();
  }

  Future<ConnectionModel?> getConnectionBetween({
    required String userId1,
    required String userId2,
  }) async {
    final data = await supabase
        .from(AppConstants.connectionsTable)
        .select()
        .or('and(requester_id.eq.$userId1,receiver_id.eq.$userId2),'
        'and(requester_id.eq.$userId2,receiver_id.eq.$userId1)')
        .maybeSingle();
    if (data == null) return null;
    return ConnectionModel.fromJson(data);
  }
}