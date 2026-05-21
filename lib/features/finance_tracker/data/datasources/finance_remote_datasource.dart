import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_map_utils.dart';
import '../../../../core/network/base_api_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../models/transaction_dto.dart';
import '../models/transaction_model.dart';

/// Remote sync: attempts API via [BaseApiService], mirrors to local snapshot on success.
class FinanceRemoteDataSource {
  FinanceRemoteDataSource({
    required BaseApiService api,
    required LocalStorageService local,
  })  : _api = api,
        _local = local;

  final BaseApiService _api;
  final LocalStorageService _local;

  Future<List<TransactionDto>> fetchSnapshot() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        ApiConstants.financeTransactions,
      );
      final map = coerceJsonMap(response.data);
      final items = (map['data'] as List<dynamic>? ?? map['items'] as List?)
              ?.map((e) => TransactionDto.fromJson(coerceJsonMap(e)))
              .toList() ??
          [];
      await _saveMirror(items);
      return items;
    } catch (_) {
      return _readMirror();
    }
  }

  Future<void> pushCreate(TransactionModel model) async {
    final dto = model.toDto();
    try {
      await _api.post<Map<String, dynamic>>(
        ApiConstants.financeTransactions,
        data: dto.toJson(),
      );
    } catch (_) {
      // Offline / missing backend — mirror still updated below.
    }
    final mirror = await _readMirror();
    mirror.removeWhere((e) => e.id == dto.id);
    mirror.add(dto);
    await _saveMirror(mirror);
  }

  Future<void> pushDelete(String id) async {
    try {
      await _api.delete<Map<String, dynamic>>(
        ApiConstants.financeTransactionById(id),
      );
    } catch (_) {
      // Mirror fallback below.
    }
    final mirror = await _readMirror();
    mirror.removeWhere((e) => e.id == id);
    await _saveMirror(mirror);
  }

  Future<List<TransactionDto>> _readMirror() async {
    final raw = _local.getString(StorageKeys.financeRemoteSnapshot);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TransactionDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _saveMirror(List<TransactionDto> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _local.setString(StorageKeys.financeRemoteSnapshot, encoded);
  }
}
