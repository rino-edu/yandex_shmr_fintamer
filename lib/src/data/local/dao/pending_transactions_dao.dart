import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/pending_transaction_table.dart';

part 'pending_transactions_dao.g.dart';

@DriftAccessor(tables: [PendingTransactions])
class PendingTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$PendingTransactionsDaoMixin {
  PendingTransactionsDao(AppDatabase db) : super(db);

  Future<List<PendingTransactionDto>> getPendingTransactions() =>
      select(pendingTransactions).get();

  Future<void> addPendingTransaction(PendingTransactionsCompanion entry) =>
      into(pendingTransactions).insert(entry);

  Future<void> deletePendingTransaction(int id) =>
      (delete(pendingTransactions)..where((t) => t.id.equals(id))).go();
}
