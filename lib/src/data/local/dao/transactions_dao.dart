import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/transaction_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  Future<void> saveTransaction(TransactionDbDto entry) {
    return into(transactions).insert(entry, mode: InsertMode.replace);
  }

  Future<void> saveTransactions(List<TransactionDbDto> entries) async {
    await batch((batch) {
      batch.insertAll(transactions, entries, mode: InsertMode.replace);
    });
  }

  Future<void> deleteTransaction(int id) {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<TransactionDbDto>> getTransactionsForAccount(int accountId) {
    return (select(transactions)
      ..where((tbl) => tbl.accountId.equals(accountId))).get();
  }
}
