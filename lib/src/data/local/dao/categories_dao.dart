import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/category_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  Future<void> saveCategories(List<CategoryDbDto> categoryList) async {
    await batch((batch) {
      batch.insertAll(categories, categoryList, mode: InsertMode.replace);
    });
  }

  Future<List<CategoryDbDto>> getCategories() => select(categories).get();

  Future<List<CategoryDbDto>> getCategoriesByType(bool isIncome) {
    return (select(categories)
      ..where((c) => c.isIncome.equals(isIncome))).get();
  }
}
