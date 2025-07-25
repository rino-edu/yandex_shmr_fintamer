import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
// Файл моков будет сгенерирован автоматически после запуска build_runner
import 'categories_repository_test.mocks.dart';

// Предполагаемый интерфейс ApiService
abstract class ApiService {
  Future<List<Category>> fetchCategories();
  Future<List<Category>> fetchCategoriesByType(bool isIncome);
}

// Реализация репозитория для тестирования
class CategoriesRepository implements ICategoriesRepository {
  final ApiService apiService;

  CategoriesRepository(this.apiService);

  @override
  Future<List<Category>> getCategories() => apiService.fetchCategories();

  @override
  Future<List<Category>> getCategoriesByType(bool isIncome) => apiService.fetchCategoriesByType(isIncome);

  @override
  Future<List<Category>> getIncomeCategories() => getCategoriesByType(true);

  @override
  Future<List<Category>> getExpenseCategories() => getCategoriesByType(false);
}

// Генерация моков
@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late CategoriesRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = CategoriesRepository(mockApiService);
  });

  group('CategoriesRepository', () {
    // Тесты для getCategories
    test('getCategories returns list of categories on success', () async {
      final categories = [
        Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
        Category(id: 2, name: 'Продукты', emoji: '🛒', isIncome: false),
      ];

      when(mockApiService.fetchCategories()).thenAnswer((_) async => categories);

      final result = await repository.getCategories();

      expect(result, equals(categories));
      verify(mockApiService.fetchCategories()).called(1);
    });

    test('getCategories throws exception on failure', () async {
      when(mockApiService.fetchCategories()).thenThrow(Exception('Ошибка сети'));

      expect(() async => await repository.getCategories(), throwsException);
      verify(mockApiService.fetchCategories()).called(1);
    });

    // Тесты для getCategoriesByType
    test('getCategoriesByType returns filtered categories on success', () async {
      final incomeCategories = [
        Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
      ];

      when(mockApiService.fetchCategoriesByType(true)).thenAnswer((_) async => incomeCategories);

      final result = await repository.getCategoriesByType(true);

      expect(result, equals(incomeCategories));
      verify(mockApiService.fetchCategoriesByType(true)).called(1);
    });

    test('getCategoriesByType throws exception on failure', () async {
      when(mockApiService.fetchCategoriesByType(false)).thenThrow(Exception('Ошибка сети'));

      expect(() async => await repository.getCategoriesByType(false), throwsException);
      verify(mockApiService.fetchCategoriesByType(false)).called(1);
    });

    // Тесты для getIncomeCategories
    test('getIncomeCategories calls getCategoriesByType with true and returns income categories', () async {
      final incomeCategories = [
        Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
      ];

      when(mockApiService.fetchCategoriesByType(true)).thenAnswer((_) async => incomeCategories);

      final result = await repository.getIncomeCategories();

      expect(result, equals(incomeCategories));
      verify(mockApiService.fetchCategoriesByType(true)).called(1);
    });

    test('getIncomeCategories throws exception on failure', () async {
      when(mockApiService.fetchCategoriesByType(true)).thenThrow(Exception('Ошибка сети'));

      expect(() async => await repository.getIncomeCategories(), throwsException);
      verify(mockApiService.fetchCategoriesByType(true)).called(1);
    });

    // Тесты для getExpenseCategories
    test('getExpenseCategories calls getCategoriesByType with false and returns expense categories', () async {
      final expenseCategories = [
        Category(id: 2, name: 'Продукты', emoji: '🛒', isIncome: false),
      ];

      when(mockApiService.fetchCategoriesByType(false)).thenAnswer((_) async => expenseCategories);

      final result = await repository.getExpenseCategories();

      expect(result, equals(expenseCategories));
      verify(mockApiService.fetchCategoriesByType(false)).called(1);
    });

    test('getExpenseCategories throws exception on failure', () async {
      when(mockApiService.fetchCategoriesByType(false)).thenThrow(Exception('Ошибка сети'));

      expect(() async => await repository.getExpenseCategories(), throwsException);
      verify(mockApiService.fetchCategoriesByType(false)).called(1);
    });
  });
}