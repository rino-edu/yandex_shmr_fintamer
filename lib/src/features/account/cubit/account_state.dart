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
  final bool isEditing;
  final bool isSaving;
  final Map<int, String> editedNames;
  final String? saveError;

  const AccountLoaded({
    required this.accounts,
    this.isBalanceVisible = true,
    this.isEditing = false,
    this.isSaving = false,
    this.editedNames = const {},
    this.saveError,
  });

  @override
  List<Object?> get props => [
    accounts,
    isBalanceVisible,
    isEditing,
    isSaving,
    editedNames,
    saveError,
  ];

  AccountLoaded copyWith({
    List<Account>? accounts,
    bool? isBalanceVisible,
    bool? isEditing,
    bool? isSaving,
    Map<int, String>? editedNames,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return AccountLoaded(
      accounts: accounts ?? this.accounts,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      editedNames: editedNames ?? this.editedNames,
      saveError: clearSaveError ? null : saveError ?? this.saveError,
    );
  }
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object> get props => [message];
}
