import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:flutter/cupertino.dart';

class ApiCategoriesRepository implements ICategoriesRepository {
  final ApiClient _apiClient;

  ApiCategoriesRepository(this._apiClient);

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      // Здесь можно обработать ошибки, например, логировать или пробрасывать кастомное исключение
      debugPrint('Error fetching all categories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getExpenseCategories() async {
    return _getCategoriesByType(isIncome: false);
  }

  @override
  Future<List<Category>> getIncomeCategories() async {
    return _getCategoriesByType(isIncome: true);
  }

  Future<List<Category>> _getCategoriesByType({required bool isIncome}) async {
    try {
      final response = await _apiClient.dio.get('/categories/type/$isIncome');
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching categories by type ($isIncome): $e');
      rethrow;
    }
  }
}
