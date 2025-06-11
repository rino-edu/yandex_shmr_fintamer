import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat_item.freezed.dart';
part 'stat_item.g.dart';

@freezed
abstract class StatItem with _$StatItem {
  const factory StatItem({
    required int categoryId,
    required String categoryName,
    required String emoji,
    required String amount,
  }) = _StatItem;

  factory StatItem.fromJson(Map<String, dynamic> json) =>
      _$StatItemFromJson(json);
}
