// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionRequest {

 int get accountId; int get categoryId; String get amount; DateTime get transactionDate; String? get comment;
/// Create a copy of TransactionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionRequestCopyWith<TransactionRequest> get copyWith => _$TransactionRequestCopyWithImpl<TransactionRequest>(this as TransactionRequest, _$identity);

  /// Serializes this TransactionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionRequest&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,amount,transactionDate,comment);

@override
String toString() {
  return 'TransactionRequest(accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $TransactionRequestCopyWith<$Res>  {
  factory $TransactionRequestCopyWith(TransactionRequest value, $Res Function(TransactionRequest) _then) = _$TransactionRequestCopyWithImpl;
@useResult
$Res call({
 int accountId, int categoryId, String amount, DateTime transactionDate, String? comment
});




}
/// @nodoc
class _$TransactionRequestCopyWithImpl<$Res>
    implements $TransactionRequestCopyWith<$Res> {
  _$TransactionRequestCopyWithImpl(this._self, this._then);

  final TransactionRequest _self;
  final $Res Function(TransactionRequest) _then;

/// Create a copy of TransactionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? transactionDate = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TransactionRequest implements TransactionRequest {
  const _TransactionRequest({required this.accountId, required this.categoryId, required this.amount, required this.transactionDate, this.comment});
  factory _TransactionRequest.fromJson(Map<String, dynamic> json) => _$TransactionRequestFromJson(json);

@override final  int accountId;
@override final  int categoryId;
@override final  String amount;
@override final  DateTime transactionDate;
@override final  String? comment;

/// Create a copy of TransactionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionRequestCopyWith<_TransactionRequest> get copyWith => __$TransactionRequestCopyWithImpl<_TransactionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionRequest&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,amount,transactionDate,comment);

@override
String toString() {
  return 'TransactionRequest(accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$TransactionRequestCopyWith<$Res> implements $TransactionRequestCopyWith<$Res> {
  factory _$TransactionRequestCopyWith(_TransactionRequest value, $Res Function(_TransactionRequest) _then) = __$TransactionRequestCopyWithImpl;
@override @useResult
$Res call({
 int accountId, int categoryId, String amount, DateTime transactionDate, String? comment
});




}
/// @nodoc
class __$TransactionRequestCopyWithImpl<$Res>
    implements _$TransactionRequestCopyWith<$Res> {
  __$TransactionRequestCopyWithImpl(this._self, this._then);

  final _TransactionRequest _self;
  final $Res Function(_TransactionRequest) _then;

/// Create a copy of TransactionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? transactionDate = null,Object? comment = freezed,}) {
  return _then(_TransactionRequest(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
