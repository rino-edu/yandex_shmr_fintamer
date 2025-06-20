import 'package:dio/dio.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:flutter/cupertino.dart';

class ApiAccountRepository implements IAccountRepository {
  final ApiClient _apiClient;

  ApiAccountRepository(this._apiClient);

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
      return Account.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }
}
