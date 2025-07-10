import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:drift/drift.dart';
import 'package:fintamer/src/core/network_status/network_status_cubit.dart';

import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/data/services/synchronization_service.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ApiTransactionsRepository implements ITransactionsRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;
  final AppDatabase _db;
  final SynchronizationService _syncService;
  final NetworkStatusCubit _networkStatusCubit;
  final _transactionsUpdateController = StreamController<void>.broadcast();

  ApiTransactionsRepository(
    this._apiClient,
    this._localDataSource,
    this._db,
    this._syncService,
    this._networkStatusCubit,
  );

  @override
  Stream<void> get onTransactionsUpdated =>
      _transactionsUpdateController.stream;

  @override
  Future<void> createTransaction({required TransactionRequest request}) async {
    final companion = PendingTransactionsCompanion.insert(
      type: 'create',
      transactionJson: jsonEncode(request.toJson()),
      createdAt: Value(DateTime.now()),
    );
    await _db.pendingTransactionsDao.addPendingTransaction(companion);
    _transactionsUpdateController.add(null);
    unawaited(_syncService.syncPendingTransactions());
  }

  @override
  Future<void> deleteTransaction({required int id}) async {
    try {
      final companion = PendingTransactionsCompanion.insert(
        type: 'delete',
        transactionId: Value(id),
        transactionJson: '',
        createdAt: Value(DateTime.now()),
      );
      await _db.pendingTransactionsDao.addPendingTransaction(companion);

      await _localDataSource.deleteTransactionById(id);
      _transactionsUpdateController.add(null);
      unawaited(_syncService.syncPendingTransactions());
    } on DioException catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionResponse>> getTransactionsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // First, try to sync any pending operations.
      await _syncService.syncPendingTransactions();

      final queryParameters = <String, dynamic>{};
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      if (startDate != null) {
        queryParameters['startDate'] = formatter.format(startDate);
      }
      if (endDate != null) {
        queryParameters['endDate'] = formatter.format(endDate);
      }

      final response = await _apiClient.dio.get(
        '/transactions/account/$accountId/period',
        queryParameters: queryParameters,
      );

      final List<dynamic> data = response.data;
      final transactions =
          data.map((json) => TransactionResponse.fromJson(json)).toList();
      await _localDataSource.saveTransactionsFromResponse(transactions);
      _networkStatusCubit.setOnline();
      return transactions;
    } on DioException catch (e) {
      debugPrint(
        'Error fetching transactions for period from API: $e. Loading from local DB.',
      );
      _networkStatusCubit.setOffline();
      try {
        return await _localDataSource.getTransactionsWithDetailsForPeriod(
          accountId: accountId,
          startDate: startDate,
          endDate: endDate,
        );
      } catch (localError) {
        debugPrint(
          'Error fetching transactions for period from local DB: $localError',
        );
        rethrow;
      }
    }
  }

  @override
  Future<void> updateTransaction({
    required int id,
    required TransactionRequest request,
  }) async {
    final companion = PendingTransactionsCompanion.insert(
      type: 'update',
      transactionId: Value(id),
      transactionJson: jsonEncode(request.toJson()),
      createdAt: Value(DateTime.now()),
    );
    await _db.pendingTransactionsDao.addPendingTransaction(companion);

    _transactionsUpdateController.add(null);
    unawaited(_syncService.syncPendingTransactions());
  }

  @override
  Future<List<TransactionResponse>> getTransactionsByAccountId({
    required int accountId,
  }) {
    return getTransactionsForPeriod(accountId: accountId);
  }
}
