import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/account/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final IAccountRepository _accountRepository;
  final ITransactionsRepository _transactionsRepository;
  StreamSubscription? _transactionsSubscription;

  AccountCubit(this._accountRepository, this._transactionsRepository)
    : super(AccountInitial()) {
    _transactionsSubscription = _transactionsRepository.onTransactionsUpdated
        .listen((_) => fetchTotalBalance());
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchTotalBalance() async {
    try {
      emit(AccountLoading());
      final accounts = await _accountRepository.getAccounts();
      if (accounts.isEmpty) {
        emit(const AccountError('У вас нет счетов'));
        return;
      }

      final totalBalance = accounts.fold<double>(
        0.0,
        (sum, acc) => sum + (double.tryParse(acc.balance) ?? 0),
      );

      final summaryAccount = AccountResponse(
        id: 0,
        name: 'Все счета',
        balance: totalBalance.toStringAsFixed(2),
        currency: accounts.first.currency,
        incomeStats: [],
        expenseStats: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      emit(AccountLoaded(account: summaryAccount));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  void toggleBalanceVisibility() {
    if (state is AccountLoaded) {
      final currentState = state as AccountLoaded;
      emit(
        currentState.copyWith(isBalanceVisible: !currentState.isBalanceVisible),
      );
    }
  }
}
