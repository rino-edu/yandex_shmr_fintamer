import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/account_table.dart';
import 'package:fintamer/src/data/local/tables/category_table.dart';
import 'package:fintamer/src/data/local/tables/transaction_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions, Accounts, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  Future<List<TypedResult>> getTransactionsWithDetailsForPeriod({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);

    query.where(transactions.accountId.equals(accountId));

    if (startDate != null) {
      query.where(transactions.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(transactions.transactionDate.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([OrderingTerm.desc(transactions.transactionDate)]);

    return query.get();
  }

  Future<void> saveTransaction(TransactionDbDto transaction) =>
      update(transactions).replace(transaction);

  Future<void> saveTransactions(List<TransactionDbDto> transactionList) async {
    await batch((batch) {
      batch.insertAll(transactions, transactionList, mode: InsertMode.replace);
    });
  }

  Future<void> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
