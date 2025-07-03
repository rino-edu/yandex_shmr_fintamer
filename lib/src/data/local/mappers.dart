import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

class Mappers {
  static CategoryDbDto toCategoryDbDto(Category category) {
    return CategoryDbDto(
      id: category.id,
      name: category.name,
      emoji: category.emoji,
      isIncome: category.isIncome,
    );
  }

  static AccountDbDto toAccountDbDto(Account account) {
    return AccountDbDto(
      id: account.id,
      userId: account.userId,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  static TransactionDbDto toTransactionDbDto(Transaction transaction) {
    return TransactionDbDto(
      id: transaction.id,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: transaction.comment,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  static TransactionDbDto fromTransactionResponse(
    TransactionResponse response,
  ) {
    return TransactionDbDto(
      id: response.id,
      accountId: response.account.id,
      categoryId: response.category.id,
      amount: response.amount,
      transactionDate: response.transactionDate,
      comment: response.comment,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }
}

extension AccountMapper on Account {
  AccountDbDto toDbDto() => AccountDbDto(
    id: id,
    userId: userId,
    name: name,
    balance: balance,
    currency: currency,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension AccountDbDtoMapper on AccountDbDto {
  Account toDomain() => Account(
    id: id,
    userId: userId,
    name: name,
    balance: balance,
    currency: currency,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension CategoryMapper on Category {
  CategoryDbDto toDbDto() =>
      CategoryDbDto(id: id, name: name, emoji: emoji, isIncome: isIncome);
}

extension CategoryDbDtoMapper on CategoryDbDto {
  Category toDomain() =>
      Category(id: id, name: name, emoji: emoji, isIncome: isIncome);
}

extension TransactionMapper on Transaction {
  TransactionDbDto toDbDto() => TransactionDbDto(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    transactionDate: transactionDate,
    comment: comment,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
