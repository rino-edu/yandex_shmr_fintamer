// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_history_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountHistoryResponse {

 int get accountId; String get accountName; String get currency; String get currentBalance;@JsonKey(toJson: _historyListToJson) List<AccountHistory> get history;
/// Create a copy of AccountHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountHistoryResponseCopyWith<AccountHistoryResponse> get copyWith => _$AccountHistoryResponseCopyWithImpl<AccountHistoryResponse>(this as AccountHistoryResponse, _$identity);

  /// Serializes this AccountHistoryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountHistoryResponse&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,accountName,currency,currentBalance,const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'AccountHistoryResponse(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
}


}

/// @nodoc
abstract mixin class $AccountHistoryResponseCopyWith<$Res>  {
  factory $AccountHistoryResponseCopyWith(AccountHistoryResponse value, $Res Function(AccountHistoryResponse) _then) = _$AccountHistoryResponseCopyWithImpl;
@useResult
$Res call({
 int accountId, String accountName, String currency, String currentBalance,@JsonKey(toJson: _historyListToJson) List<AccountHistory> history
});




}
/// @nodoc
class _$AccountHistoryResponseCopyWithImpl<$Res>
    implements $AccountHistoryResponseCopyWith<$Res> {
  _$AccountHistoryResponseCopyWithImpl(this._self, this._then);

  final AccountHistoryResponse _self;
  final $Res Function(AccountHistoryResponse) _then;

/// Create a copy of AccountHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? accountName = null,Object? currency = null,Object? currentBalance = null,Object? history = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AccountHistory>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccountHistoryResponse implements AccountHistoryResponse {
  const _AccountHistoryResponse({required this.accountId, required this.accountName, required this.currency, required this.currentBalance, @JsonKey(toJson: _historyListToJson) required final  List<AccountHistory> history}): _history = history;
  factory _AccountHistoryResponse.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseFromJson(json);

@override final  int accountId;
@override final  String accountName;
@override final  String currency;
@override final  String currentBalance;
 final  List<AccountHistory> _history;
@override@JsonKey(toJson: _historyListToJson) List<AccountHistory> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of AccountHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountHistoryResponseCopyWith<_AccountHistoryResponse> get copyWith => __$AccountHistoryResponseCopyWithImpl<_AccountHistoryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountHistoryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountHistoryResponse&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&const DeepCollectionEquality().equals(other._history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,accountName,currency,currentBalance,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'AccountHistoryResponse(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
}


}

/// @nodoc
abstract mixin class _$AccountHistoryResponseCopyWith<$Res> implements $AccountHistoryResponseCopyWith<$Res> {
  factory _$AccountHistoryResponseCopyWith(_AccountHistoryResponse value, $Res Function(_AccountHistoryResponse) _then) = __$AccountHistoryResponseCopyWithImpl;
@override @useResult
$Res call({
 int accountId, String accountName, String currency, String currentBalance,@JsonKey(toJson: _historyListToJson) List<AccountHistory> history
});




}
/// @nodoc
class __$AccountHistoryResponseCopyWithImpl<$Res>
    implements _$AccountHistoryResponseCopyWith<$Res> {
  __$AccountHistoryResponseCopyWithImpl(this._self, this._then);

  final _AccountHistoryResponse _self;
  final $Res Function(_AccountHistoryResponse) _then;

/// Create a copy of AccountHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? accountName = null,Object? currency = null,Object? currentBalance = null,Object? history = null,}) {
  return _then(_AccountHistoryResponse(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<AccountHistory>,
  ));
}


}

// dart format on
