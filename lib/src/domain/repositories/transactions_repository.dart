import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';

abstract class ITransactionsRepository {
  Stream<void> get onTransactionsUpdated;

  Future<List<TransactionResponse>> getTransactionsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<TransactionResponse>> getTransactionsByAccountId({
    required int accountId,
  }) => getTransactionsForPeriod(accountId: accountId);

  Future<void> createTransaction({required TransactionRequest request});

  Future<void> updateTransaction({
    required int id,
    required TransactionRequest request,
  });

  Future<void> deleteTransaction({required int id});
}
