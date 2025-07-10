import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:flutter/material.dart';

part 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  AddTransactionCubit({
    required ITransactionsRepository transactionsRepository,
    required IAccountRepository accountRepository,
    required ICategoriesRepository categoriesRepository,
    required this.isIncome,
    this.transaction,
  }) : _transactionsRepository = transactionsRepository,
       _accountRepository = accountRepository,
       _categoriesRepository = categoriesRepository,
       super(
         AddTransactionState(
           isIncome: isIncome,
           initialTransaction: transaction,
         ),
       ) {
    init();
  }

  final ITransactionsRepository _transactionsRepository;
  final IAccountRepository _accountRepository;
  final ICategoriesRepository _categoriesRepository;
  final bool isIncome;
  final TransactionResponse? transaction;

  void init() {
    _loadAccounts();
    _loadCategories();

    if (state.isEditing) {
      final tr = state.initialTransaction!;
      emit(
        state.copyWith(
          category: () => tr.category,
          amount: tr.amount,
          date: tr.transactionDate,
          comment: tr.comment,
        ),
      );
    } else {
      emit(state.copyWith(date: DateTime.now()));
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _accountRepository.getAccounts();
      if (accounts.isNotEmpty) {
        emit(
          state.copyWith(
            accounts: accounts,
            selectedAccount:
                state.isEditing
                    ? accounts.firstWhere(
                      (a) => a.id == state.initialTransaction!.account.id,
                      orElse: () => accounts.first,
                    )
                    : accounts.first,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: 'Failed to load accounts',
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories =
          isIncome
              ? await _categoriesRepository.getIncomeCategories()
              : await _categoriesRepository.getExpenseCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: 'Failed to load categories',
        ),
      );
    }
  }

  void onAccountSelected(Account account) {
    emit(state.copyWith(selectedAccount: account));
  }

  void onAmountChanged(String amount) {
    emit(state.copyWith(amount: amount));
  }

  void onCategorySelected(Category category) {
    emit(state.copyWith(category: () => category));
  }

  void onDateChanged(DateTime date) {
    final oldDate = state.date ?? DateTime.now();
    emit(
      state.copyWith(
        date: date.copyWith(hour: oldDate.hour, minute: oldDate.minute),
      ),
    );
  }

  void onTimeChanged(TimeOfDay time) {
    final oldDate = state.date ?? DateTime.now();
    emit(
      state.copyWith(
        date: oldDate.copyWith(hour: time.hour, minute: time.minute),
      ),
    );
  }

  void onCommentChanged(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> saveTransaction() async {
    if (state.category == null ||
        state.date == null ||
        state.selectedAccount == null ||
        state.amount.isEmpty) {
      emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: 'Please fill all required fields.',
        ),
      );
      emit(state.copyWith(status: AddTransactionStatus.initial)); // reset
      return;
    }
    emit(state.copyWith(status: AddTransactionStatus.loading));
    try {
      final request = TransactionRequest(
        accountId: state.selectedAccount!.id,
        categoryId: state.category!.id,
        amount: state.amount,
        transactionDate: state.date!.toUtc(),
        comment: state.comment,
      );
      if (state.isEditing) {
        await _transactionsRepository.updateTransaction(
          id: state.initialTransaction!.id,
          request: request,
        );
      } else {
        await _transactionsRepository.createTransaction(request: request);
      }
      emit(state.copyWith(status: AddTransactionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: 'An error occurred: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteTransaction() async {
    if (!state.isEditing) return;
    emit(state.copyWith(status: AddTransactionStatus.loading));
    try {
      await _transactionsRepository.deleteTransaction(
        id: state.initialTransaction!.id,
      );
      emit(state.copyWith(status: AddTransactionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: 'An error occurred: ${e.toString()}',
        ),
      );
    }
  }
}
