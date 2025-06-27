import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/account_response.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final AccountResponse account;
  final bool isBalanceVisible;

  const AccountLoaded({required this.account, this.isBalanceVisible = true});

  @override
  List<Object?> get props => [account, isBalanceVisible];

  AccountLoaded copyWith({AccountResponse? account, bool? isBalanceVisible}) {
    return AccountLoaded(
      account: account ?? this.account,
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
