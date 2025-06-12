import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';

abstract class ITransactionsRepository {

  Future<List<TransactionResponse>> getTransactionsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Transaction> createTransaction({required TransactionRequest request});

  Future<TransactionResponse> updateTransaction({
    required int id,
    required TransactionRequest request,
  });

  Future<void> deleteTransaction({required int id});
}
