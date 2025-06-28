import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final bool isBalanceVisible;

  const AccountLoaded({required this.accounts, this.isBalanceVisible = true});

  @override
  List<Object?> get props => [accounts, isBalanceVisible];

  AccountLoaded copyWith({List<Account>? accounts, bool? isBalanceVisible}) {
    return AccountLoaded(
      accounts: accounts ?? this.accounts,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object> get props => [message];
}
