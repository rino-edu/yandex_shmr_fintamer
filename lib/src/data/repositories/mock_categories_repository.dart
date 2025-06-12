import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';

class MockCategoriesRepository implements ICategoriesRepository {
  List<Category>? _cachedCategories;

  Future<List<Category>> _loadCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/mock_data/categories.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedCategories =
        jsonList.map((json) => Category.fromJson(json)).toList();
    return _cachedCategories!;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );
    return _loadCategories();
  }

  @override
  Future<List<Category>> getExpenseCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allCategories = await _loadCategories();
    return allCategories.where((c) => !c.isIncome).toList();
  }

  @override
  Future<List<Category>> getIncomeCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allCategories = await _loadCategories();
    return allCategories.where((c) => c.isIncome).toList();
  }
}
