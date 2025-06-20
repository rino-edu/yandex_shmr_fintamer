import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';
import 'package:fintamer/src/domain/models/stat_item.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';

class MockAccountRepository implements IAccountRepository {
  Future<AccountResponse> _loadAccountResponse() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock_data/account.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final account = Account.fromJson(json);

    return AccountResponse(
      id: account.id,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
      incomeStats: const [],
      expenseStats: const [],
    );
  }

  @override
  Future<AccountResponse> getAccount({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _loadAccountResponse();
  }

  @override
  Future<Account> updateAccount({
    required int id,
    required AccountUpdateRequest request,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    debugPrint('Имитация обновления счета с id: $id, новые данные: ${request.name}');
    final jsonString = await rootBundle.loadString(
      'assets/mock_data/account.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final account = Account.fromJson(json);
    return account.copyWith(
      name: request.name,
      balance: request.balance,
      currency: request.currency,
    );
  }
}
