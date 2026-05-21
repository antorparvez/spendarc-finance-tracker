enum PendingSyncActionType { create, delete }

class PendingSyncAction {
  const PendingSyncAction({
    required this.fingerprint,
    required this.action,
    required this.transactionId,
    required this.payload,
    required this.createdAtMs,
  });

  final String fingerprint;
  final PendingSyncActionType action;
  final String transactionId;
  final Map<String, dynamic> payload;
  final int createdAtMs;

  factory PendingSyncAction.fromJson(Map<String, dynamic> json) {
    return PendingSyncAction(
      fingerprint: json['fingerprint']?.toString() ?? '',
      action: json['action']?.toString() == 'delete'
          ? PendingSyncActionType.delete
          : PendingSyncActionType.create,
      transactionId: json['transactionId']?.toString() ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'fingerprint': fingerprint,
        'action': action.name,
        'transactionId': transactionId,
        'payload': payload,
        'createdAtMs': createdAtMs,
      };
}
