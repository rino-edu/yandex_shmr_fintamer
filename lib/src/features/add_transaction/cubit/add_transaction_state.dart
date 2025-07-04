part of 'add_transaction_cubit.dart';

enum AddTransactionStatus { initial, loading, success, failure }

@immutable
class AddTransactionState extends Equatable {
  const AddTransactionState({
    this.status = AddTransactionStatus.initial,
    this.isIncome = false,
    this.accounts = const [],
    this.categories = const [],
    this.selectedAccount,
    this.category,
    this.amount = '',
    this.date,
    this.comment,
    this.initialTransaction,
    this.errorMessage,
  });

  final AddTransactionStatus status;
  final bool isIncome;
  final List<Account> accounts;
  final List<Category> categories;
  final Account? selectedAccount;
  final Category? category;
  final String amount;
  final DateTime? date;
  final String? comment;
  final TransactionResponse? initialTransaction;
  final String? errorMessage;

  bool get isEditing => initialTransaction != null;

  AddTransactionState copyWith({
    AddTransactionStatus? status,
    bool? isIncome,
    List<Account>? accounts,
    List<Category>? categories,
    Account? selectedAccount,
    Category? category,
    String? amount,
    DateTime? date,
    String? comment,
    TransactionResponse? initialTransaction,
    String? errorMessage,
  }) {
    return AddTransactionState(
      status: status ?? this.status,
      isIncome: isIncome ?? this.isIncome,
      accounts: accounts ?? this.accounts,
      categories: categories ?? this.categories,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      initialTransaction: initialTransaction ?? this.initialTransaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isIncome,
    accounts,
    categories,
    selectedAccount,
    category,
    amount,
    date,
    comment,
    initialTransaction,
    errorMessage,
  ];
}
