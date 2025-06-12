import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintamer/src/data/repositories/mock_categories_repository.dart';
import 'package:fintamer/src/domain/models/category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCategoriesRepository repository;

  setUp(() {
    repository = MockCategoriesRepository();
  });

  test('getAllCategories должен возвращать список категорий из JSON', () async {
    final jsonString = await rootBundle.loadString('assets/mock_data/categories.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final expectedCategories = jsonList.map((json) => Category.fromJson(json)).toList();

    final actualCategories = await repository.getAllCategories();

    expect(actualCategories, isA<List<Category>>());
    expect(actualCategories.length, expectedCategories.length);
    expect(actualCategories, equals(expectedCategories));
  });

  test('getIncomeCategories должен возвращать только категории доходов', () async {
    final incomeCategories = await repository.getIncomeCategories();

    expect(incomeCategories.every((c) => c.isIncome), isTrue);
    expect(incomeCategories.any((c) => !c.isIncome), isFalse);
  });
}