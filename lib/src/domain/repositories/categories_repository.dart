import 'package:fintamer/src/domain/models/category.dart';

abstract class ICategoriesRepository {

  Future<List<Category>> getAllCategories();

  Future<List<Category>> getIncomeCategories();

  Future<List<Category>> getExpenseCategories();
}
