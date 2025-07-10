import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart' as foundation;

class ApiCategoriesRepository implements ICategoriesRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;

  ApiCategoriesRepository(this._apiClient, this._localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final List<dynamic> data = response.data;
      final categories = data.map((json) => Category.fromJson(json)).toList();
      await _localDataSource.saveCategories(categories);
      return categories;
    } on DioException catch (e) {
      foundation.debugPrint(
        'Error fetching categories from API: $e. Loading from local DB.',
      );
      try {
        return await _localDataSource.getCategories();
      } catch (localError) {
        foundation.debugPrint(
          'Error fetching categories from local DB: $localError',
        );
        rethrow;
      }
    }
  }

  @override
  Future<List<Category>> getCategoriesByType(bool isIncome) async {
    try {
      final response = await _apiClient.dio.get('/categories/type/$isIncome');
      final List<dynamic> data = response.data;
      final categories = data.map((json) => Category.fromJson(json)).toList();
      // We can also cache these results, but it might mix with the full list.
      // For now, let's just ensure it works. A more robust caching would be needed for full offline.
      return categories;
    } on DioException catch (e) {
      foundation.debugPrint(
        'Error fetching categories by type ($isIncome) from API: $e. Loading from local DB.',
      );
      try {
        return await _localDataSource.getCategoriesByType(isIncome);
      } catch (localError) {
        foundation.debugPrint(
          'Error fetching categories by type from local DB: $localError',
        );
        rethrow;
      }
    }
  }

  @override
  Future<List<Category>> getExpenseCategories() {
    return getCategoriesByType(false);
  }

  @override
  Future<List<Category>> getIncomeCategories() {
    return getCategoriesByType(true);
  }
}
