import 'package:dio/dio.dart';
import 'package:fintamer/src/core/network_status/network_status_cubit.dart';
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
  final NetworkStatusCubit _networkStatusCubit;

  ApiAccountRepository(
    this._apiClient,
    this._localDataSource,
    this._networkStatusCubit,
  );

  @override
  Future<List<Account>> getAccounts() async {
    try {
      final response = await _apiClient.dio.get('/accounts');
      final List<dynamic> data = response.data;
      final accounts = data.map((json) => Account.fromJson(json)).toList();
      await _localDataSource.saveAccounts(accounts);
      _networkStatusCubit.setOnline();
      return accounts;
    } on DioException catch (e) {
      debugPrint(
        'Error fetching accounts from API: $e. Loading from local DB.',
      );
      _networkStatusCubit.setOffline();
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
      _networkStatusCubit.setOnline();
      return AccountResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching account: $e');
      _networkStatusCubit.setOffline();
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
      _networkStatusCubit.setOnline();
      return account;
    } on DioException catch (e) {
      debugPrint('Error updating account: $e');
      _networkStatusCubit.setOffline();
      rethrow;
    }
  }
}
