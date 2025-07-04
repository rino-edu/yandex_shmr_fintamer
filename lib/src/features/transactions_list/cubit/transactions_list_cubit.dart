import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';

part 'transactions_list_state.dart';

class TransactionsListCubit extends Cubit<TransactionsListState> {
  final ITransactionsRepository _transactionsRepository;
  final IAccountRepository _accountRepository;
  final bool _isIncome;
  StreamSubscription? _transactionsSubscription;

  TransactionsListCubit({
    required ITransactionsRepository transactionsRepository,
    required IAccountRepository accountRepository,
    required bool isIncome,
  }) : _transactionsRepository = transactionsRepository,
       _accountRepository = accountRepository,
       _isIncome = isIncome,
       super(TransactionsListInitial()) {
    _transactionsSubscription = _transactionsRepository.onTransactionsUpdated
        .listen((_) => loadTransactions());
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> loadTransactions() async {
    try {
      emit(TransactionsListLoading());

      final accounts = await _accountRepository.getAccounts();
      if (accounts.isEmpty) {
        emit(const TransactionsListLoaded([], 0.0));
        return;
      }

      final now = DateTime.now().toUtc();
      final from = DateTime.utc(now.year, now.month, now.day);
      final to = DateTime.utc(now.year, now.month, now.day, 23, 59, 59, 999);

      final transactionFutures =
          accounts
              .map(
                (account) => _transactionsRepository.getTransactionsForPeriod(
                  accountId: account.id,
                  startDate: from,
                  endDate: to,
                ),
              )
              .toList();

      final results = await Future.wait(transactionFutures);
      final allTransactions = results.expand((e) => e).toList();

      final filteredTransactions =
          allTransactions
              .where(
                (transaction) => transaction.category.isIncome == _isIncome,
              )
              .toList();

      filteredTransactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );

      final totalAmount = filteredTransactions.fold<double>(
        0.0,
        (sum, transaction) => sum + double.parse(transaction.amount),
      );

      emit(TransactionsListLoaded(filteredTransactions, totalAmount));
    } catch (e) {
      emit(TransactionsListError(e.toString()));
    }
  }
}
