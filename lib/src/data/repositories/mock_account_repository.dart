import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';

class MockAccountRepository implements IAccountRepository {
  Future<Account> _loadAccount() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock_data/account.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Account.fromJson(json);
  }

  @override
  Future<Account> getAccount({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _loadAccount();
  }

  @override
  Future<Account> updateAccount({
    required int id,
    required AccountUpdateRequest request,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    print('Имитация обновления счета с id: $id, новые данные: ${request.name}');
    return _loadAccount();
  }
}
