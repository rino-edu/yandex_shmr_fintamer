import 'package:flutter_test/flutter_test.dart';
import 'package:fintamer/src/domain/models/account_brief.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

void main() {
  group('TransactionResponse Model Tests', () {
    // 1. Arrange: Подготавливаем тестовые данные

    // Эталонный Dart-объект, который мы ожидаем получить
    final tTransactionResponseModel = TransactionResponse(
      id: 1,
      account: const AccountBrief(
        id: 10,
        name: 'Основной счёт',
        balance: '10000.00',
        currency: 'RUB',
      ),
      category: const Category(
        id: 20,
        name: 'Продукты',
        emoji: '🛒',
        isIncome: false,
      ),
      amount: '250.50',
      transactionDate: DateTime.parse("2024-07-29T10:00:00.000Z"),
      comment: 'Покупка в магазине',
      createdAt: DateTime.parse("2024-07-29T10:00:05.000Z"),
      updatedAt: DateTime.parse("2024-07-29T10:00:05.000Z"),
    );

    // Эталонный JSON, который мы как будто получили от сервера
    final tTransactionResponseJson = {
      "id": 1,
      "account": {
        "id": 10,
        "name": "Основной счёт",
        "balance": "10000.00",
        "currency": "RUB"
      },
      "category": {
        "id": 20,
        "name": "Продукты",
        "emoji": "🛒",
        "isIncome": false
      },
      "amount": "250.50",
      "transactionDate": "2024-07-29T10:00:00.000Z",
      "comment": "Покупка в магазине",
      "createdAt": "2024-07-29T10:00:05.000Z",
      "updatedAt": "2024-07-29T10:00:05.000Z"
    };


    test('fromJson должен корректно создавать модель из JSON', () {
      // 2. Act: Выполняем действие
      final result = TransactionResponse.fromJson(tTransactionResponseJson);

      // 3. Assert: Проверяем результат
      // Мы ожидаем, что модель, созданная из JSON, будет идентична нашему эталонному объекту
      expect(result, tTransactionResponseModel);
    });

    test('toJson должен корректно преобразовывать модель в JSON', () {
      // 2. Act: Выполняем действие
      final result = tTransactionResponseModel.toJson();

      // 3. Assert: Проверяем результат
      // Мы ожидаем, что JSON, созданный из нашей модели, будет идентичен эталонному JSON
      expect(result, tTransactionResponseJson);
    });
  });
}