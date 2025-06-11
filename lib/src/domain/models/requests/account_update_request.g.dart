// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountUpdateRequest _$AccountUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _AccountUpdateRequest(
  name: json['name'] as String,
  balance: json['balance'] as String,
  currency: json['currency'] as String,
);

Map<String, dynamic> _$AccountUpdateRequestToJson(
  _AccountUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'balance': instance.balance,
  'currency': instance.currency,
};
