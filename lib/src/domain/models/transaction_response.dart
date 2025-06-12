import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account_brief.dart';
import 'category.dart';

part 'transaction_response.freezed.dart';
part 'transaction_response.g.dart';

@freezed
abstract class TransactionResponse with _$TransactionResponse {
  const factory TransactionResponse({
    required int id,
    @JsonKey(toJson: _accountBriefToJson) required AccountBrief account,
    @JsonKey(toJson: _categoryToJson) required Category category,
    required String amount,
    required DateTime transactionDate,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionResponse;

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);
}

Map<String, dynamic>? _accountBriefToJson(AccountBrief? instance) =>
    instance?.toJson();

Map<String, dynamic>? _categoryToJson(Category? instance) => instance?.toJson();
