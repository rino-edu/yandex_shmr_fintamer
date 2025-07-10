import 'package:dio/dio.dart';
import 'package:fintamer/src/core/error/exceptions.dart';
import 'package:fintamer/src/core/network_status/network_status_cubit.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart' as foundation;

class ApiCategoriesRepository implements ICategoriesRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;
  final NetworkStatusCubit _networkStatusCubit;

  ApiCategoriesRepository(
    this._apiClient,
    this._localDataSource,
    this._networkStatusCubit,
  );

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final categories = response.data as List<Category>;
      await _localDataSource.saveCategories(categories);
      _networkStatusCubit.setOnline();
      return categories;
    } on NetworkException catch (e) {
      foundation.debugPrint(
        '${e.runtimeType}: ${e.message}. Loading from local DB.',
      );
      _networkStatusCubit.setOffline();
      try {
        return await _localDataSource.getCategories();
      } catch (_) {
        throw CacheException(message: 'Failed to load categories from cache.');
      }
    } on ServerException catch (e) {
      foundation.debugPrint('${e.runtimeType}: ${e.message}.');
      _networkStatusCubit.setOffline();
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesByType(bool isIncome) async {
    try {
      final response = await _apiClient.dio.get('/categories/type/$isIncome');
      final categories = response.data as List<Category>;
      // We can also cache these results, but it might mix with the full list.
      // For now, let's just ensure it works. A more robust caching would be needed for full offline.
      _networkStatusCubit.setOnline();
      return categories;
    } on NetworkException catch (e) {
      foundation.debugPrint(
        '${e.runtimeType} for type ($isIncome): ${e.message}. Loading from local DB.',
      );
      _networkStatusCubit.setOffline();
      try {
        return await _localDataSource.getCategoriesByType(isIncome);
      } catch (_) {
        throw CacheException(
          message: 'Failed to load categories by type from cache.',
        );
      }
    } on ServerException catch (e) {
      foundation.debugPrint('${e.runtimeType}: ${e.message}.');
      _networkStatusCubit.setOffline();
      rethrow;
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
