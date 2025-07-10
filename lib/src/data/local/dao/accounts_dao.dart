import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/account_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(AppDatabase db) : super(db);

  Future<void> saveAccount(AccountDbDto account) =>
      update(accounts).replace(account);

  Future<void> saveAccounts(List<AccountDbDto> accountList) async {
    await batch((batch) {
      batch.insertAll(accounts, accountList, mode: InsertMode.replace);
    });
  }

  Future<List<AccountDbDto>> getAccounts() => select(accounts).get();
}
