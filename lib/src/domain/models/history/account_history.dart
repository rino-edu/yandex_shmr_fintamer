import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account_state.dart';

part 'account_history.freezed.dart';
part 'account_history.g.dart';

enum ChangeType { CREATION, MODIFICATION }

@freezed
abstract class AccountHistory with _$AccountHistory {
  const factory AccountHistory({
    required int id,
    required int accountId,
    required ChangeType changeType,
    @JsonKey(toJson: _accountStateToJson) AccountState? previousState,
    @JsonKey(toJson: _accountStateToJson) required AccountState newState,
    required DateTime changeTimestamp,
    required DateTime createdAt,
  }) = _AccountHistory;

  factory AccountHistory.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryFromJson(json);
}

Map<String, dynamic>? _accountStateToJson(AccountState? instance) =>
    instance?.toJson();
