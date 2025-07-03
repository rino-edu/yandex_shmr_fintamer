import 'package:fintamer/src/domain/models/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'categories_state.freezed.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState.initial() = CategoriesInitial;
  const factory CategoriesState.loading() = CategoriesLoading;
  const factory CategoriesState.loaded({
    required List<Category> allCategories,
    required List<Category> filteredCategories,
  }) = CategoriesLoaded;
  const factory CategoriesState.error(String message) = CategoriesError;
}
