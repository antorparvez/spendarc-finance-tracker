import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import 'transaction_dto.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.syncVersion,
    this.isPending = false,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final int createdAtMs;
  final int updatedAtMs;
  final int syncVersion;
  final bool isPending;

  factory TransactionModel.fromDto(TransactionDto dto, {bool isPending = false}) {
    return TransactionModel(
      id: dto.id,
      title: dto.title,
      amount: dto.amount,
      type: _typeFromString(dto.type),
      category: dto.category,
      createdAtMs: dto.createdAtMs,
      updatedAtMs: dto.updatedAtMs,
      syncVersion: dto.syncVersion,
      isPending: isPending,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel.fromDto(TransactionDto.fromJson(json),
        isPending: json['isPending'] == true);
  }

  TransactionDto toDto() {
    return TransactionDto(
      id: id,
      title: title,
      amount: amount,
      type: type.name,
      category: category,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncVersion: syncVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        ...toDto().toJson(),
        'isPending': isPending,
      };

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    int? createdAtMs,
    int? updatedAtMs,
    int? syncVersion,
    bool? isPending,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      syncVersion: syncVersion ?? this.syncVersion,
      isPending: isPending ?? this.isPending,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      syncVersion: syncVersion,
      isPending: isPending,
    );
  }

  static TransactionType _typeFromString(String raw) {
    return raw == TransactionType.income.name
        ? TransactionType.income
        : TransactionType.expense;
  }
}
