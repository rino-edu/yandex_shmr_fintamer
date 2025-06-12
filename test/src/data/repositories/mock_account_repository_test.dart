import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintamer/src/data/repositories/mock_account_repository.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAccountRepository repository;

  setUp(() {
    repository = MockAccountRepository();
  });

  group('MockAccountRepository Tests', () {
    test('getAccount должен возвращать счет из JSON', () async {
      final jsonString = await rootBundle.loadString(
        'assets/mock_data/account.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final expectedAccount = Account.fromJson(json);

      final actualAccount = await repository.getAccount(id: 101);

      expect(actualAccount, isA<Account>());
      expect(actualAccount, equals(expectedAccount));
    });

    test('updateAccount должен возвращать тот же счет для имитации', () async {
      final jsonString = await rootBundle.loadString(
        'assets/mock_data/account.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final expectedAccount = Account.fromJson(json);

      final request = AccountUpdateRequest(
        name: "Новое имя",
        balance: "12345.67",
        currency: "USD",
      );

      final actualAccount = await repository.updateAccount(
        id: 101,
        request: request,
      );

      expect(actualAccount, isA<Account>());
      expect(actualAccount, equals(expectedAccount));
    });
  });
}
