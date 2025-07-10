import 'package:drift/drift.dart';

@DataClassName('PendingTransactionDto')
class PendingTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  TextColumn get transactionJson => text().named('transaction_json')();

  IntColumn get transactionId => integer().nullable().named('transaction_id')();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
