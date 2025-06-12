import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_create_request.freezed.dart';
part 'account_create_request.g.dart';

@freezed
abstract class AccountCreateRequest with _$AccountCreateRequest {
  const factory AccountCreateRequest({
    required String name,
    required String balance,
    required String currency,
  }) = _AccountCreateRequest;

  factory AccountCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountCreateRequestFromJson(json);
}
