import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/mappers.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

class DriftLocalDataSource {
  final AppDatabase _db;

  DriftLocalDataSource(this._db);

  Future<void> saveCategories(List<Category> categories) async {
    final dtos = categories.map(Mappers.toCategoryDbDto).toList();
    await _db.categoriesDao.saveCategories(dtos);
  }

  Future<void> saveAccount(Account account) async {
    final dto = Mappers.toAccountDbDto(account);
    await _db.accountsDao.saveAccount(dto);
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final dto = Mappers.toTransactionDbDto(transaction);
    await _db.transactionsDao.saveTransaction(dto);
  }

  Future<void> saveTransactionsFromResponse(
    List<TransactionResponse> transactions,
  ) async {
    final transactionDtos =
        transactions.map(Mappers.fromTransactionResponse).toList();
    final categoryDtos =
        transactions.map((e) => Mappers.toCategoryDbDto(e.category)).toList();

    await _db.categoriesDao.saveCategories(categoryDtos);
    await _db.transactionsDao.saveTransactions(transactionDtos);
  }

  Future<void> saveTransactionFromResponse(
    TransactionResponse transaction,
  ) async {
    final transactionDto = Mappers.fromTransactionResponse(transaction);
    final categoryDto = Mappers.toCategoryDbDto(transaction.category);

    await _db.categoriesDao.saveCategories([categoryDto]);
    await _db.transactionsDao.saveTransaction(transactionDto);
  }

  Future<void> deleteTransactionById(int id) async {
    await _db.transactionsDao.deleteTransaction(id);
  }
}
