import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fintamer/src/data/local/dao/accounts_dao.dart';
import 'package:fintamer/src/data/local/dao/categories_dao.dart';
import 'package:fintamer/src/data/local/dao/transactions_dao.dart';
import 'package:fintamer/src/data/local/tables/account_table.dart';
import 'package:fintamer/src/data/local/tables/category_table.dart';
import 'package:fintamer/src/data/local/tables/transaction_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

@DriftDatabase(
  tables: [Accounts, Categories, Transactions],
  daos: [AccountsDao, CategoriesDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fintamer.sqlite'));
    return NativeDatabase(file);
  });
}
