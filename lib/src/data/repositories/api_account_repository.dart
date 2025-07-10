import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_brief.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:flutter/cupertino.dart';

class ApiAccountRepository implements IAccountRepository {
  final ApiClient _apiClient;
  final DriftLocalDataSource _localDataSource;

  ApiAccountRepository(this._apiClient, this._localDataSource);

  @override
  Future<List<Account>> getAccounts() async {
    try {
      final response = await _apiClient.dio.get('/accounts');
      final List<dynamic> data = response.data;
      final accounts = data.map((json) => Account.fromJson(json)).toList();
      await _localDataSource.saveAccounts(accounts);
      return accounts;
    } on DioException catch (e) {
      debugPrint(
        'Error fetching accounts from API: $e. Loading from local DB.',
      );
      try {
        return await _localDataSource.getAccounts();
      } catch (localError) {
        debugPrint('Error fetching accounts from local DB: $localError');
        rethrow;
      }
    }
  }

  @override
  Future<AccountResponse> getAccount({required int id}) async {
    try {
      final response = await _apiClient.dio.get('/accounts/$id');
      return AccountResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching account: $e');
      rethrow;
    }
  }

  @override
  Future<Account> updateAccount({
    required int id,
    required AccountUpdateRequest request,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/accounts/$id',
        data: request.toJson(),
      );
      final account = Account.fromJson(response.data);
      _localDataSource.saveAccount(account);
      return account;
    } on DioException catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }
}
