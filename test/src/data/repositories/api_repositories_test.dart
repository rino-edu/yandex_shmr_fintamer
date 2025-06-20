import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/repositories/api_account_repository.dart';
import 'package:fintamer/src/data/repositories/api_categories_repository.dart';
import 'package:fintamer/src/data/repositories/api_transactions_repository.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';

void main() {
  late final IAccountRepository accountRepo;
  late final ICategoriesRepository categoriesRepo;
  late final ITransactionsRepository transactionsRepo;

  // setUpAll - это специальная функция, которая запускается один раз
  // перед всеми тестами в этом файле. Это самое правильное место для инициализации.
  setUpAll(() async {
    // Этот хак по-прежнему нужен, чтобы разрешить реальные HTTP-запросы
    HttpOverrides.global = null;
    // Инициализируем Flutter-окружение, чтобы можно было загрузить .env из assets
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    // Создаем экземпляры наших сервисов ПОСЛЕ того, как все настроено
    final apiClient = ApiClient();
    accountRepo = ApiAccountRepository(apiClient);
    categoriesRepo = ApiCategoriesRepository(apiClient);
    transactionsRepo = ApiTransactionsRepository(apiClient);
  });

  group('API Repositories Integration Tests', () {
    test('Should fetch all categories from API', () async {
      try {
        final categories = await categoriesRepo.getAllCategories();

        // Проверяем, что список не пустой
        expect(categories, isNotEmpty);

        print('--- ✅ [SUCCESS] Fetched All Categories ---');
        // Печатаем каждую категорию для наглядности
        for (var category in categories) {
          print('  - ${category.toJson()}');
        }
        print('--------------------------------------------\n');
      } catch (e) {
        print('--- ❌ [FAILURE] Could not fetch categories ---');
        print(e);
        fail('Test failed due to an exception.');
      }
    });

    test('Should fetch account details from API', () async {
      // ВАЖНО: Укажите ID существующего счета в вашем API
      const accountId = 1;

      try {
        final accountResponse = await accountRepo.getAccount(id: accountId);

        // Проверяем, что ID в ответе совпадает с запрошенным
        expect(accountResponse.id, accountId);

        print('--- ✅ [SUCCESS] Fetched Account Response (ID: $accountId) ---');
        print('  - ${accountResponse.toJson()}');
        print('-----------------------------------------------------\n');
      } catch (e) {
        print('--- ❌ [FAILURE] Could not fetch account ID: $accountId ---');
        print(e);
        fail('Test failed due to an exception.');
      }
    });

    test('Should fetch transactions for an account from API', () async {
      // ВАЖНО: Укажите ID существующего счета в вашем API
      const accountId = 1;

      try {
        final transactions = await transactionsRepo.getTransactionsByAccountId(
          accountId: accountId,
        );

        // Проверяем, что ответ не null (список может быть пустым)
        expect(transactions, isNotNull);

        print(
          '--- ✅ [SUCCESS] Fetched Transactions (Account ID: $accountId) ---',
        );
        if (transactions.isEmpty) {
          print('  - No transactions found for this account.');
        } else {
          for (var t in transactions) {
            print('  - ${t.toJson()}');
          }
        }
        print('------------------------------------------------------------\n');
      } catch (e) {
        print(
          '--- ❌ [FAILURE] Could not fetch transactions for account ID: $accountId ---',
        );
        print(e);
        fail('Test failed due to an exception.');
      }
    });
  });
}
