import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';

class MockTransactionsRepository implements ITransactionsRepository {
  Future<List<TransactionResponse>> _loadTransactions() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock_data/transactions.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => TransactionResponse.fromJson(json)).toList();
  }

  @override
  Future<Transaction> createTransaction({
    required TransactionRequest request,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('Имитация создания транзакции: ${request.amount}');
    return Transaction(
      id: Random().nextInt(1000) + 100, // Случайный ID
      accountId: request.accountId,
      categoryId: request.categoryId,
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteTransaction({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('Имитация удаления транзакции с id: $id');
    return;
  }

  @override
  Future<List<TransactionResponse>> getTransactionsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allTransactions = await _loadTransactions();
    var filteredTransactions =
        allTransactions.where((t) => t.account.id == accountId).toList();

    if (startDate != null) {
      filteredTransactions =
          filteredTransactions
              .where((t) => t.transactionDate.isAfter(startDate))
              .toList();
    }
    if (endDate != null) {
      filteredTransactions =
          filteredTransactions
              .where((t) => t.transactionDate.isBefore(endDate))
              .toList();
    }
    return filteredTransactions;
  }

  @override
  Future<TransactionResponse> updateTransaction({
    required int id,
    required TransactionRequest request,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('Имитация обновления транзакции с id: $id');
    final mockTransaction = (await _loadTransactions()).first;
    return mockTransaction.copyWith(
      amount: request.amount,
      comment: request.comment,
      transactionDate: request.transactionDate,
    );
  }

  @override
  Future<List<TransactionResponse>> getTransactionsByAccountId({
    required int accountId,
  }) {
    return getTransactionsForPeriod(accountId: accountId);
  }
}
