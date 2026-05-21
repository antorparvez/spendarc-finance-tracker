/// Wire-format DTO for API / remote snapshot JSON.
class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.syncVersion,
  });

  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncVersion;

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: json['type']?.toString() ?? 'expense',
      category: json['category']?.toString() ?? 'general',
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
      syncVersion: (json['syncVersion'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'syncVersion': syncVersion,
      };
}
