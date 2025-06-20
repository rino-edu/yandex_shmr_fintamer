part of 'add_transaction_cubit.dart';

enum AddTransactionStatus { initial, loading, success, failure }

class AddTransactionState extends Equatable {
  const AddTransactionState({
    this.status = AddTransactionStatus.initial,
    this.initialTransaction,
    required this.isIncome,
    this.accountName,
    this.category,
    this.amount = '0',
    this.date,
    this.comment,
    this.errorMessage,
  });

  final AddTransactionStatus status;
  final TransactionResponse? initialTransaction;
  final bool isIncome;
  final String? accountName;
  final Category? category;
  final String amount;
  final DateTime? date;
  final String? comment;
  final String? errorMessage;

  bool get isEditing => initialTransaction != null;

  AddTransactionState copyWith({
    AddTransactionStatus? status,
    TransactionResponse? initialTransaction,
    bool? isIncome,
    String? accountName,
    Category? category,
    String? amount,
    DateTime? date,
    String? comment,
    String? errorMessage,
  }) {
    return AddTransactionState(
      status: status ?? this.status,
      initialTransaction: initialTransaction ?? this.initialTransaction,
      isIncome: isIncome ?? this.isIncome,
      accountName: accountName ?? this.accountName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialTransaction,
    isIncome,
    accountName,
    category,
    amount,
    date,
    comment,
    errorMessage,
  ];
}
