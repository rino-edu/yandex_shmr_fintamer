import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintamer/src/data/repositories/mock_transactions_repository.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTransactionsRepository repository;

  setUp(() {
    repository = MockTransactionsRepository();
  });

  group('MockTransactionsRepository Tests', () {
    test(
      'getTransactionsForPeriod должен возвращать список транзакций из JSON',
      () async {
        final jsonString = await rootBundle.loadString(
          'assets/mock_data/transactions.json',
        );
        final List<dynamic> jsonList = json.decode(jsonString);
        final expectedTransactions =
            jsonList.map((json) => TransactionResponse.fromJson(json)).toList();

        final actualTransactions = await repository.getTransactionsForPeriod(
          accountId: 101,
        );

        expect(actualTransactions, isA<List<TransactionResponse>>());
        expect(actualTransactions.length, expectedTransactions.length);
        expect(actualTransactions, equals(expectedTransactions));
      },
    );

    test('createTransaction должен возвращать фейковую транзакцию', () async {
      final request = TransactionRequest(
        accountId: 101,
        categoryId: 1,
        amount: '100.00',
        transactionDate: DateTime.now(),
      );

      final result = await repository.createTransaction(request: request);

      expect(result, isA<Transaction>());
      expect(result.accountId, request.accountId);
      expect(result.amount, request.amount);
    });

    test('deleteTransaction должен завершаться без ошибок', () async {
      expectLater(repository.deleteTransaction(id: 1), completes);
    });

    test(
      'updateTransaction должен возвращать обновленную транзакцию',
      () async {
        final request = TransactionRequest(
          accountId: 101,
          categoryId: 2,
          amount: '999.99',
          comment: 'Обновленный коммент',
          transactionDate: DateTime.now(),
        );

        final result = await repository.updateTransaction(
          id: 1,
          request: request,
        );

        expect(result, isA<TransactionResponse>());
        expect(result.amount, request.amount);
        expect(result.comment, request.comment);
      },
    );
  });
}
