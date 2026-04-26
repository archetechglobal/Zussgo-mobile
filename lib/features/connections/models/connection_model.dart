enum ConnectionStatus { pending, accepted, declined }

class ConnectionModel {
  final String id;
  final String requesterId;
  final String receiverId;
  final ConnectionStatus status;
  final DateTime createdAt;

  const ConnectionModel({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id:          json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId:  json['receiver_id'] as String,
      status:      ConnectionStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String),
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}