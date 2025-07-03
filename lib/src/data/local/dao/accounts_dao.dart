import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/account_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(AppDatabase db) : super(db);

  Future<List<AccountDbDto>> getAccounts() => select(accounts).get();

  Future<void> saveAccount(AccountDbDto entry) {
    return into(accounts).insert(entry, mode: InsertMode.replace);
  }

  Future<void> saveAccounts(List<AccountDbDto> entries) async {
    await batch((batch) {
      batch.insertAll(accounts, entries, mode: InsertMode.replace);
    });
  }
}
