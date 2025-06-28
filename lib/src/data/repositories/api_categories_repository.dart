import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:flutter/cupertino.dart';

class ApiCategoriesRepository implements ICategoriesRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;

  ApiCategoriesRepository(this._apiClient, this._localDataSource);

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final List<dynamic> data = response.data;
      final categories = data.map((json) => Category.fromJson(json)).toList();
      _localDataSource.saveCategories(categories);
      return categories;
    } on DioException catch (e) {
      // Здесь можно обработать ошибки, например, логировать или пробрасывать кастомное исключение
      debugPrint('Error fetching all categories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getExpenseCategories() async {
    final categories = await _getCategoriesByType(isIncome: false);
    _localDataSource.saveCategories(categories);
    return categories;
  }

  @override
  Future<List<Category>> getIncomeCategories() async {
    final categories = await _getCategoriesByType(isIncome: true);
    _localDataSource.saveCategories(categories);
    return categories;
  }

  Future<List<Category>> _getCategoriesByType({required bool isIncome}) async {
    try {
      final response = await _apiClient.dio.get('/categories/type/$isIncome');
      final List<dynamic> data = response.data;
      final categories = data.map((json) => Category.fromJson(json)).toList();
      _localDataSource.saveCategories(categories);
      return categories;
    } on DioException catch (e) {
      debugPrint('Error fetching categories by type ($isIncome): $e');
      rethrow;
    }
  }
}
