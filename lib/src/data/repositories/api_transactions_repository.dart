import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ApiTransactionsRepository implements ITransactionsRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;
  final _transactionsUpdateController = StreamController<void>.broadcast();

  ApiTransactionsRepository(this._apiClient, this._localDataSource);

  @override
  Stream<void> get onTransactionsUpdated =>
      _transactionsUpdateController.stream;

  @override
  Future<Transaction> createTransaction({
    required TransactionRequest request,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/transactions',
        data: request.toJson(),
      );
      final transaction = Transaction.fromJson(response.data);
      await _localDataSource.saveTransaction(transaction);
      _transactionsUpdateController.add(null);
      return transaction;
    } on DioException catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction({required int id}) async {
    try {
      await _apiClient.dio.delete('/transactions/$id');
      await _localDataSource.deleteTransactionById(id);
      _transactionsUpdateController.add(null);
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
      return transactions;
    } on DioException catch (e) {
      debugPrint('Error fetching transactions for period: $e');
      rethrow;
    }
  }

  @override
  Future<TransactionResponse> updateTransaction({
    required int id,
    required TransactionRequest request,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/transactions/$id',
        data: request.toJson(),
      );
      final transactionResponse = TransactionResponse.fromJson(response.data);
      await _localDataSource.saveTransactionFromResponse(transactionResponse);
      _transactionsUpdateController.add(null);
      return transactionResponse;
    } on DioException catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionResponse>> getTransactionsByAccountId({
    required int accountId,
  }) {
    return getTransactionsForPeriod(accountId: accountId);
  }
}
