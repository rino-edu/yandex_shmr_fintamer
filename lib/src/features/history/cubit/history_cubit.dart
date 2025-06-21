import 'package:bloc/bloc.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/history/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final ITransactionsRepository _transactionsRepository;
  final IAccountRepository _accountRepository;

  HistoryCubit({
    required ITransactionsRepository transactionsRepository,
    required IAccountRepository accountRepository,
  }) : _transactionsRepository = transactionsRepository,
       _accountRepository = accountRepository,
       super(HistoryState.initial());

  Future<void> loadHistory({required bool isIncome}) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final accounts = await _accountRepository.getAccounts();
      final accountIds = accounts.map((e) => e.id).toList();

      final List<TransactionResponse> allTransactions = [];
      final start = DateTime(
        state.startDate.year,
        state.startDate.month,
        state.startDate.day,
      );
      final end = DateTime(
        state.endDate.year,
        state.endDate.month,
        state.endDate.day,
        23,
        59,
        59,
      );

      for (final accountId in accountIds) {
        final transactions = await _transactionsRepository
            .getTransactionsForPeriod(
              accountId: accountId,
              startDate: start,
              endDate: end,
            );
        allTransactions.addAll(transactions);
      }

      final filteredTransactions =
          allTransactions.where((t) {
            return t.category.isIncome == isIncome;
          }).toList();

      if (state.sortType == HistorySortType.byDate) {
        filteredTransactions.sort(
          (a, b) => b.transactionDate.compareTo(a.transactionDate),
        );
      } else {
        filteredTransactions.sort((a, b) {
          final amountA = double.tryParse(a.amount) ?? 0.0;
          final amountB = double.tryParse(b.amount) ?? 0.0;
          return amountB.compareTo(amountA);
        });
      }

      double total = 0;
      for (var t in filteredTransactions) {
        total += double.tryParse(t.amount) ?? 0.0;
      }

      emit(
        state.copyWith(
          status: HistoryStatus.success,
          transactions: filteredTransactions,
          totalAmount: total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateStartDate({
    required DateTime startDate,
    required bool isIncome,
  }) async {
    if (startDate.isAfter(state.endDate)) {
      emit(state.copyWith(startDate: startDate, endDate: startDate));
    } else {
      emit(state.copyWith(startDate: startDate));
    }
    await loadHistory(isIncome: isIncome);
  }

  Future<void> updateEndDate({
    required DateTime endDate,
    required bool isIncome,
  }) async {
    if (endDate.isBefore(state.startDate)) {
      emit(state.copyWith(endDate: endDate, startDate: endDate));
    } else {
      emit(state.copyWith(endDate: endDate));
    }
    await loadHistory(isIncome: isIncome);
  }

  Future<void> updateSortType({
    required HistorySortType sortType,
    required bool isIncome,
  }) async {
    emit(state.copyWith(sortType: sortType));
    await loadHistory(isIncome: isIncome);
  }
}
