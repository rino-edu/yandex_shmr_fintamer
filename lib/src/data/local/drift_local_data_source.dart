import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:fintamer/src/data/local/dao/accounts_dao.dart';
import 'package:fintamer/src/data/local/dao/categories_dao.dart';
import 'package:fintamer/src/data/local/dao/transactions_dao.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/mappers.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_brief.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/requests/transaction_request.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

E? _firstWhereOrNull<E>(List<E> items, bool Function(E) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

class DriftLocalDataSource {
  final AppDatabase _db;

  DriftLocalDataSource(this._db);

  AccountsDao get _accountsDao => _db.accountsDao;
  CategoriesDao get _categoriesDao => _db.categoriesDao;
  TransactionsDao get _transactionsDao => _db.transactionsDao;

  Future<void> saveAccount(Account account) async {
    return _accountsDao.saveAccount(account.toDbDto());
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    final dtos = accounts.map((a) => a.toDbDto()).toList();
    return _accountsDao.saveAccounts(dtos);
  }

  Future<List<Account>> getAccounts() async {
    final dtos = await _accountsDao.getAccounts();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final dtos = categories.map((c) => c.toDbDto()).toList();
    return _categoriesDao.saveCategories(dtos);
  }

  Future<List<Category>> getCategories() async {
    final dtos = await _categoriesDao.getCategories();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<List<Category>> getCategoriesByType(bool isIncome) async {
    final dtos = await _categoriesDao.getCategoriesByType(isIncome);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    return _transactionsDao.saveTransaction(transaction.toDbDto());
  }

  Future<void> saveTransactionsFromResponse(
    List<TransactionResponse> transactions,
  ) async {
    final transactionDtos =
        transactions.map(Mappers.fromTransactionResponse).toList();
    final categoryDtos =
        transactions.map((e) => Mappers.toCategoryDbDto(e.category)).toList();

    await _categoriesDao.saveCategories(categoryDtos);
    await _transactionsDao.saveTransactions(transactionDtos);
  }

  Future<void> saveTransactionFromResponse(
    TransactionResponse transaction,
  ) async {
    final transactionDto = Mappers.fromTransactionResponse(transaction);
    final categoryDto = Mappers.toCategoryDbDto(transaction.category);

    await _categoriesDao.saveCategories([categoryDto]);
    await _transactionsDao.saveTransaction(transactionDto);
  }

  Future<void> deleteTransactionById(int id) async {
    await _transactionsDao.deleteTransaction(id);
  }

  Future<List<TransactionResponse>> getTransactionsWithDetailsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Get already synced transactions from the main tables
    final results = await _transactionsDao.getTransactionsWithDetailsForPeriod(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );

    final syncedTransactions =
        results.map((row) {
          final transactionDto = row.readTable(_db.transactions);
          final accountDto = row.readTable(_db.accounts);
          final categoryDto = row.readTable(_db.categories);

          return TransactionResponse(
            id: transactionDto.id,
            amount: transactionDto.amount,
            comment: transactionDto.comment,
            transactionDate: transactionDto.transactionDate,
            createdAt: transactionDto.createdAt,
            updatedAt: transactionDto.updatedAt,
            account: AccountBrief(
              id: accountDto.id,
              name: accountDto.name,
              balance: accountDto.balance,
              currency: accountDto.currency,
            ),
            category: Category(
              id: categoryDto.id,
              name: categoryDto.name,
              emoji: categoryDto.emoji,
              isIncome: categoryDto.isIncome,
            ),
          );
        }).toList();

    // 2. Get pending creations to show them optimistically
    final pendingCreations =
        (await _db.pendingTransactionsDao.getPendingTransactions())
            .where((op) => op.type == 'create')
            .toList();

    if (pendingCreations.isEmpty) {
      return syncedTransactions;
    }

    // 3. Construct TransactionResponse for pending items
    final List<TransactionResponse> pendingResponses = [];
    final allAccounts = await getAccounts();
    final allCategories = await getCategories();

    for (final op in pendingCreations) {
      final request = TransactionRequest.fromJson(
        jsonDecode(op.transactionJson),
      );

      // Filter by account and date range, just like the main query
      if (request.accountId != accountId) continue;
      if (startDate != null && request.transactionDate.isBefore(startDate))
        continue;
      if (endDate != null && request.transactionDate.isAfter(endDate)) continue;

      final account = _firstWhereOrNull(
        allAccounts,
        (a) => a.id == request.accountId,
      );
      final category = _firstWhereOrNull(
        allCategories,
        (c) => c.id == request.categoryId,
      );

      if (account == null || category == null) continue;

      pendingResponses.add(
        TransactionResponse(
          id: -op.id, // Use negative ID to signify a temporary local transaction
          amount: request.amount,
          comment: request.comment,
          transactionDate: request.transactionDate,
          createdAt: op.createdAt,
          updatedAt: op.createdAt,
          account: AccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
          ),
          category: category,
        ),
      );
    }

    // 4. Combine and sort
    final combinedList = [...syncedTransactions, ...pendingResponses];
    combinedList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return combinedList;
  }
}
