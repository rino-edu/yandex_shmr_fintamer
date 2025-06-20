part of 'transactions_list_cubit.dart';

abstract class TransactionsListState extends Equatable {
  const TransactionsListState();

  @override
  List<Object> get props => [];
}

class TransactionsListInitial extends TransactionsListState {}

class TransactionsListLoading extends TransactionsListState {}

class TransactionsListLoaded extends TransactionsListState {
  final List<TransactionResponse> transactions;
  final double totalAmount;

  const TransactionsListLoaded(this.transactions, this.totalAmount);

  @override
  List<Object> get props => [transactions, totalAmount];
}

class TransactionsListError extends TransactionsListState {
  final String message;

  const TransactionsListError(this.message);

  @override
  List<Object> get props => [message];
}
