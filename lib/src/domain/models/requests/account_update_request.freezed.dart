// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountUpdateRequest {

 String get name; String get balance; String get currency;
/// Create a copy of AccountUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountUpdateRequestCopyWith<AccountUpdateRequest> get copyWith => _$AccountUpdateRequestCopyWithImpl<AccountUpdateRequest>(this as AccountUpdateRequest, _$identity);

  /// Serializes this AccountUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountUpdateRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,balance,currency);

@override
String toString() {
  return 'AccountUpdateRequest(name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $AccountUpdateRequestCopyWith<$Res>  {
  factory $AccountUpdateRequestCopyWith(AccountUpdateRequest value, $Res Function(AccountUpdateRequest) _then) = _$AccountUpdateRequestCopyWithImpl;
@useResult
$Res call({
 String name, String balance, String currency
});




}
/// @nodoc
class _$AccountUpdateRequestCopyWithImpl<$Res>
    implements $AccountUpdateRequestCopyWith<$Res> {
  _$AccountUpdateRequestCopyWithImpl(this._self, this._then);

  final AccountUpdateRequest _self;
  final $Res Function(AccountUpdateRequest) _then;

/// Create a copy of AccountUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? balance = null,Object? currency = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccountUpdateRequest implements AccountUpdateRequest {
  const _AccountUpdateRequest({required this.name, required this.balance, required this.currency});
  factory _AccountUpdateRequest.fromJson(Map<String, dynamic> json) => _$AccountUpdateRequestFromJson(json);

@override final  String name;
@override final  String balance;
@override final  String currency;

/// Create a copy of AccountUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountUpdateRequestCopyWith<_AccountUpdateRequest> get copyWith => __$AccountUpdateRequestCopyWithImpl<_AccountUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountUpdateRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,balance,currency);

@override
String toString() {
  return 'AccountUpdateRequest(name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$AccountUpdateRequestCopyWith<$Res> implements $AccountUpdateRequestCopyWith<$Res> {
  factory _$AccountUpdateRequestCopyWith(_AccountUpdateRequest value, $Res Function(_AccountUpdateRequest) _then) = __$AccountUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String balance, String currency
});




}
/// @nodoc
class __$AccountUpdateRequestCopyWithImpl<$Res>
    implements _$AccountUpdateRequestCopyWith<$Res> {
  __$AccountUpdateRequestCopyWithImpl(this._self, this._then);

  final _AccountUpdateRequest _self;
  final $Res Function(_AccountUpdateRequest) _then;

/// Create a copy of AccountUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? balance = null,Object? currency = null,}) {
  return _then(_AccountUpdateRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
