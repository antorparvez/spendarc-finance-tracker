import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/transaction_type.dart';
import 'finance_json_isolate.dart';
import '../models/transaction_model.dart';

/// Local cache (instant reads) backed by SharedPreferences JSON.
class FinanceLocalDataSource {
  FinanceLocalDataSource(this._local);

  final LocalStorageService _local;
  final _controller = StreamController<List<TransactionModel>>.broadcast();

  static const double defaultMonthlyBudget = 5000;

  Stream<List<TransactionModel>> watchAll() async* {
    yield await getAll();
    yield* _controller.stream;
  }

  Future<List<TransactionModel>> getAll() async {
    final raw = _local.getString(StorageKeys.financeTransactions);
    if (raw == null || raw.isEmpty) {
      return _seedIfEmpty();
    }
    final maps = await compute(decodeTransactionJsonList, raw);
    return maps
        .map(TransactionModel.fromJson)
        .toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
  }

  Future<List<TransactionModel>> _seedIfEmpty() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final seed = [
      TransactionModel(
        id: 'seed-1',
        title: 'Salary',
        amount: 3200,
        type: TransactionType.income,
        category: 'work',
        createdAtMs: now - 86400000 * 3,
        updatedAtMs: now - 86400000 * 3,
        syncVersion: 1,
      ),
      TransactionModel(
        id: 'seed-2',
        title: 'Groceries',
        amount: 84.5,
        type: TransactionType.expense,
        category: 'food',
        createdAtMs: now - 86400000 * 2,
        updatedAtMs: now - 86400000 * 2,
        syncVersion: 1,
      ),
      TransactionModel(
        id: 'seed-3',
        title: 'Transport',
        amount: 42,
        type: TransactionType.expense,
        category: 'travel',
        createdAtMs: now - 86400000,
        updatedAtMs: now - 86400000,
        syncVersion: 1,
      ),
    ];
    await saveAll(seed);
    return seed;
  }

  Future<void> saveAll(List<TransactionModel> items) async {
    final sorted = [...items]
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    final encoded =
        jsonEncode(sorted.map((e) => e.toJson()).toList(growable: false));
    await _local.setString(StorageKeys.financeTransactions, encoded);
    _controller.add(sorted);
  }

  Future<void> upsert(TransactionModel model) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == model.id);
    if (index >= 0) {
      items[index] = model;
    } else {
      items.insert(0, model);
    }
    await saveAll(items);
  }

  Future<void> removeById(String id) async {
    final items = await getAll()..removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  void dispose() {
    _controller.close();
  }
}
