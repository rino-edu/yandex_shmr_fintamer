import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_brief.freezed.dart';
part 'account_brief.g.dart';

@freezed
abstract class AccountBrief with _$AccountBrief {
  const factory AccountBrief({
    required int id,
    required String name,
    required String balance,
    required String currency,
  }) = _AccountBrief;

  factory AccountBrief.fromJson(Map<String, dynamic> json) =>
      _$AccountBriefFromJson(json);
}
