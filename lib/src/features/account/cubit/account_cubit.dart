import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
        .listen((_) => fetchAccounts());
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchAccounts() async {
    try {
      emit(AccountLoading());
      final accounts = await _accountRepository.getAccounts();
      if (accounts.isEmpty) {
        emit(const AccountError('У вас нет счетов'));
        return;
      }
      emit(AccountLoaded(accounts: accounts));
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
