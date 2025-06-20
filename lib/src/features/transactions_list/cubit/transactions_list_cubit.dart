import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';

part 'transactions_list_state.dart';

class TransactionsListCubit extends Cubit<TransactionsListState> {
  final ITransactionsRepository _transactionsRepository;
  static const int _accountId = 1;

  TransactionsListCubit({
    required ITransactionsRepository transactionsRepository,
  }) : _transactionsRepository = transactionsRepository,
       super(TransactionsListInitial());

  Future<void> loadTransactions({required bool isIncome}) async {
    try {
      emit(TransactionsListLoading());

      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day);
      final to = from.add(const Duration(days: 1));

      final allTransactions = await _transactionsRepository
          .getTransactionsForPeriod(
            accountId: _accountId,
            startDate: from,
            endDate: to,
          );

      final filteredTransactions =
          allTransactions
              .where((transaction) => transaction.category.isIncome == isIncome)
              .toList();

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
