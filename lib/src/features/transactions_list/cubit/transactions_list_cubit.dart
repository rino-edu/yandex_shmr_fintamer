import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';

part 'transactions_list_state.dart';

class TransactionsListCubit extends Cubit<TransactionsListState> {
  final ITransactionsRepository _transactionsRepository;
  final IAccountRepository _accountRepository;

  TransactionsListCubit({
    required ITransactionsRepository transactionsRepository,
    required IAccountRepository accountRepository,
  }) : _transactionsRepository = transactionsRepository,
       _accountRepository = accountRepository,
       super(TransactionsListInitial());

  Future<void> loadTransactions({required bool isIncome}) async {
    try {
      emit(TransactionsListLoading());

      final accounts = await _accountRepository.getAccounts();
      if (accounts.isEmpty) {
        emit(const TransactionsListLoaded([], 0.0));
        return;
      }

      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day);

      final transactionFutures =
          accounts
              .map(
                (account) => _transactionsRepository.getTransactionsForPeriod(
                  accountId: account.id,
                  startDate: from,
                  endDate: from,
                ),
              )
              .toList();

      final results = await Future.wait(transactionFutures);
      final allTransactions = results.expand((e) => e).toList();

      final filteredTransactions =
          allTransactions
              .where((transaction) => transaction.category.isIncome == isIncome)
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
