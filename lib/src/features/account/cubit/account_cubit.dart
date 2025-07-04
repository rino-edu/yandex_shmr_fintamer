import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/account/cubit/account_state.dart';
import 'package:flutter/foundation.dart';

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
      final chartData = await _getChartData(accounts);
      emit(AccountLoaded(accounts: accounts, dailySummaries: chartData));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<Map<int, double>> _getChartData(List<Account> accounts) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final allTransactions = <TransactionResponse>[];
    for (final account in accounts) {
      final transactions = await _transactionsRepository
          .getTransactionsForPeriod(
            accountId: account.id,
            startDate: startDate,
            endDate: endDate,
          );
      allTransactions.addAll(transactions);
    }
    final groupedTransactions = groupBy(
      allTransactions,
      (t) => t.transactionDate.day,
    );
    return groupedTransactions.map((day, transactions) {
      final total = transactions.fold<double>(0.0, (sum, t) {
        final amount = double.tryParse(t.amount) ?? 0.0;
        return sum + (t.category.isIncome ? amount : -amount);
      });
      return MapEntry(day, total);
    });
  }

  void enterEditMode() {
    if (state is! AccountLoaded) return;
    final currentState = state as AccountLoaded;
    emit(currentState.copyWith(isEditing: true));
  }

  void exitEditMode() {
    if (state is! AccountLoaded) return;
    final currentState = state as AccountLoaded;
    emit(currentState.copyWith(isEditing: false, editedNames: {}));
  }

  void onAccountNameChanged(int accountId, String newName) {
    if (state is! AccountLoaded) return;
    final currentState = state as AccountLoaded;

    final newEditedNames = Map<int, String>.from(currentState.editedNames);
    newEditedNames[accountId] = newName;

    emit(currentState.copyWith(editedNames: newEditedNames));
  }

  Future<void> saveChanges() async {
    if (state is! AccountLoaded) return;
    final currentState = state as AccountLoaded;

    if (currentState.editedNames.isEmpty) {
      exitEditMode();
      return;
    }

    emit(currentState.copyWith(isSaving: true, clearSaveError: true));

    try {
      final originalAccounts = await _accountRepository.getAccounts();

      final updateFutures = currentState.editedNames.entries.map((entry) {
        final accountId = entry.key;
        final newName = entry.value.trim();

        if (newName.isEmpty) {
          throw Exception('Название счета не может быть пустым.');
        }
        if (newName.length > 255) {
          throw Exception('Название счета не может быть длиннее 255 символов.');
        }

        final originalAccount = originalAccounts.firstWhere(
          (acc) => acc.id == accountId,
        );

        final request = AccountUpdateRequest(
          name: newName,
          balance: originalAccount.balance,
          currency: originalAccount.currency,
        );
        return _accountRepository.updateAccount(
          id: accountId,
          request: request,
        );
      });

      await Future.wait(updateFutures);

      await fetchAccounts();
      final newState = this.state as AccountLoaded;
      emit(newState.copyWith(isEditing: false, editedNames: {}));
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          saveError: e.toString().replaceFirst("Exception: ", ""),
        ),
      );
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

  Future<void> changeAccountCurrency(int accountId, String newCurrency) async {
    if (state is! AccountLoaded) return;
    final currentState = state as AccountLoaded;

    final account = currentState.accounts.firstWhere(
      (acc) => acc.id == accountId,
    );

    final name = currentState.editedNames[accountId] ?? account.name;

    emit(currentState.copyWith(isSaving: true, saveError: null));

    try {
      final request = AccountUpdateRequest(
        name: name,
        balance: account.balance,
        currency: newCurrency,
      );

      final updatedAccount = await _accountRepository.updateAccount(
        id: accountId,
        request: request,
      );

      final newAccounts =
          currentState.accounts.map((e) {
            if (e.id == accountId) {
              return updatedAccount;
            }
            return e;
          }).toList();

      emit(currentState.copyWith(accounts: newAccounts, isSaving: false));
    } catch (e, st) {
      if (kDebugMode) {
        print('Error changing currency: $e\n$st');
      }
      emit(
        currentState.copyWith(
          saveError: 'Не удалось обновить валюту',
          isSaving: false,
        ),
      );
    }
  }
}
