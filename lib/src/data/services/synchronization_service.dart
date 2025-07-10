import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/dao/pending_transactions_dao.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:flutter/foundation.dart';

class SynchronizationService {
  final ApiClient _apiClient;
  final AppDatabase _db;
  bool _isSyncing = false;

  PendingTransactionsDao get _pendingDao => _db.pendingTransactionsDao;

  SynchronizationService(this._apiClient, this._db);

  Future<void> syncPendingTransactions() async {
    if (_isSyncing) {
      debugPrint('Sync Service: Already syncing, skipping subsequent call.');
      return;
    }

    _isSyncing = true;
    try {
      final pendingOperations = await _pendingDao.getPendingTransactions();

      if (pendingOperations.isEmpty) {
        debugPrint('Sync Service: No pending operations to sync.');
        return;
      }

      debugPrint(
        'Sync Service: Found ${pendingOperations.length} pending operations. Starting sync...',
      );

      for (final operation in pendingOperations) {
        try {
          bool success = false;
          switch (operation.type) {
            case 'create':
              final request = TransactionRequest.fromJson(
                jsonDecode(operation.transactionJson),
              );
              await _apiClient.dio.post(
                '/transactions',
                data: request.toJson(),
              );
              success = true;
              break;
            case 'update':
              final request = TransactionRequest.fromJson(
                jsonDecode(operation.transactionJson),
              );
              await _apiClient.dio.put(
                '/transactions/${operation.transactionId}',
                data: request.toJson(),
              );
              success = true;
              break;
            case 'delete':
              await _apiClient.dio.delete(
                '/transactions/${operation.transactionId}',
              );
              success = true;
              break;
          }

          if (success) {
            await _pendingDao.deletePendingTransaction(operation.id);
            debugPrint(
              'Sync Service: Successfully synced and removed operation ${operation.id} (${operation.type})',
            );
          }
        } on DioException catch (e) {
          debugPrint(
            'Sync Service: Failed to sync operation ${operation.id}. Error: $e',
          );
          // The operation remains in the queue for the next attempt.
        } catch (e) {
          debugPrint(
            'Sync Service: An unexpected error occurred during sync of operation ${operation.id}. Error: $e',
          );
        }
      }
      debugPrint('Sync Service: Sync process finished.');
    } finally {
      _isSyncing = false;
    }
  }
}
