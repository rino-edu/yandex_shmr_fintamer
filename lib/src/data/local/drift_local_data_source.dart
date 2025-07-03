import 'package:fintamer/src/data/local/dao/accounts_dao.dart';
import 'package:fintamer/src/data/local/dao/categories_dao.dart';
import 'package:fintamer/src/data/local/dao/transactions_dao.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/mappers.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

class DriftLocalDataSource {
  final AppDatabase _db;

  DriftLocalDataSource(this._db);

  AccountsDao get _accountsDao => _db.accountsDao;
  CategoriesDao get _categoriesDao => _db.categoriesDao;
  TransactionsDao get _transactionsDao => _db.transactionsDao;

  Future<void> saveAccount(Account account) async {
    return _accountsDao.saveAccount(account.toDbDto());
  }

  Future<void> saveCategories(List<Category> categories) async {
    final dtos = categories.map((c) => c.toDbDto()).toList();
    return _categoriesDao.saveCategories(dtos);
  }

  Future<List<Category>> getCategories() async {
    final dtos = await _categoriesDao.getCategories();
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
}
