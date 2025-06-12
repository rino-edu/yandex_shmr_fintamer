// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) =>
    _TransactionRequest(
      accountId: (json['accountId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      amount: json['amount'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$TransactionRequestToJson(_TransactionRequest instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'comment': instance.comment,
    };
