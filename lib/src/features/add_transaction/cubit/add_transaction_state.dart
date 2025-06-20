part of 'add_transaction_cubit.dart';

enum AddTransactionStatus { initial, loading, success, failure }

class AddTransactionState extends Equatable {
  const AddTransactionState({
    this.status = AddTransactionStatus.initial,
    this.initialTransaction,
    required this.isIncome,
    this.accounts = const [],
    this.selectedAccount,
    this.category,
    this.amount = '0',
    this.date,
    this.comment,
    this.errorMessage,
  });

  final AddTransactionStatus status;
  final TransactionResponse? initialTransaction;
  final bool isIncome;
  final List<AccountBrief> accounts;
  final AccountBrief? selectedAccount;
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
    List<AccountBrief>? accounts,
    AccountBrief? selectedAccount,
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
      accounts: accounts ?? this.accounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
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
    accounts,
    selectedAccount,
    category,
    amount,
    date,
    comment,
    errorMessage,
  ];
}
