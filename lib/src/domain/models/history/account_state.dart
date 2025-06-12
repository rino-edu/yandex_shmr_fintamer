import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_state.freezed.dart';
part 'account_state.g.dart';

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    required int id,
    required String name,
    required String balance,
    required String currency,
  }) = _AccountState;

  factory AccountState.fromJson(Map<String, dynamic> json) =>
      _$AccountStateFromJson(json);
}
