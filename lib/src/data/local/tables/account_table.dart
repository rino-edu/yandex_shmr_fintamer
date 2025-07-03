import 'package:drift/drift.dart';

@DataClassName('AccountDbDto')
class Accounts extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get name => text()();
  TextColumn get balance => text()();
  TextColumn get currency => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
