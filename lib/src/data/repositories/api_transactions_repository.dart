import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ApiTransactionsRepository implements ITransactionsRepository {
  final ApiClient _apiClient;

  ApiTransactionsRepository(this._apiClient);

  @override
  Future<Transaction> createTransaction({
    required TransactionRequest request,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/transactions',
        data: request.toJson(),
      );
      return Transaction.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction({required int id}) async {
    try {
      await _apiClient.dio.delete('/transactions/$id');
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
      return data.map((json) => TransactionResponse.fromJson(json)).toList();
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
      return TransactionResponse.fromJson(response.data);
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
