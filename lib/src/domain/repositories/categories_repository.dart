import 'package:fintamer/src/domain/models/category.dart';

abstract class ICategoriesRepository {
  Future<List<Category>> getCategoriesByType(bool isIncome);

  Future<List<Category>> getCategories();

  Future<List<Category>> getIncomeCategories();

  Future<List<Category>> getExpenseCategories();
}
