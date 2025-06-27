import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/tables/account_table.dart';
import 'package:fintamer/src/data/local/tables/category_table.dart';

@DataClassName('TransactionDbDto')
class Transactions extends Table {
  IntColumn get id => integer()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get amount => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get comment => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
