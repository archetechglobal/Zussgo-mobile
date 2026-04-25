// lib/features/connections/models/connection_model.dart

import '../../profile/models/profile_model.dart';

class ConnectionModel {
  final String id;
  final String requesterId;
  final String receiverId;
  final String? tripId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final ProfileModel? requester;
  final ProfileModel? receiver;
  final Map<String, dynamic>? trip;

  const ConnectionModel({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    this.tripId,
    required this.status,
    this.message,
    required this.createdAt,
    this.requester,
    this.receiver,
    this.trip,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> m) {
    final req = m['requester'] as Map<String, dynamic>?;
    final rec = m['receiver']  as Map<String, dynamic>?;
    return ConnectionModel(
      id:          m['id'] as String,
      requesterId: m['requester_id'] as String,
      receiverId:  m['receiver_id']  as String,
      tripId:      m['trip_id']      as String?,
      status:      m['status']       as String,
      message:     m['message']      as String?,
      createdAt:   DateTime.parse(m['created_at'] as String),
      requester:   req != null ? ProfileModel.fromMap(req) : null,
      receiver:    rec != null ? ProfileModel.fromMap(rec) : null,
      trip:        m['trip'] as Map<String, dynamic>?,
    );
  }

  // The "other" person relative to current user
  ProfileModel? peer(String myId) =>
      requesterId == myId ? receiver : requester;
}