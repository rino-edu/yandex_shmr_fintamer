import 'package:drift/drift.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/tables/category_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  Future<List<CategoryDbDto>> getAllCategories() => select(categories).get();

  Future<List<CategoryDbDto>> getIncomeCategories() {
    return (select(categories)
      ..where((tbl) => tbl.isIncome.equals(true))).get();
  }

  Future<List<CategoryDbDto>> getExpenseCategories() {
    return (select(categories)
      ..where((tbl) => tbl.isIncome.equals(false))).get();
  }

  Future<void> saveCategories(List<CategoryDbDto> entries) async {
    await batch((batch) {
      batch.insertAll(categories, entries, mode: InsertMode.replace);
    });
  }
}
