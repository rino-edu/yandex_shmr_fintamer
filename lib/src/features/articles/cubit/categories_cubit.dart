import 'package:bloc/bloc.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/features/articles/cubit/categories_state.dart';
import 'package:fuzzy/fuzzy.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final ICategoriesRepository _categoriesRepository;

  CategoriesCubit(this._categoriesRepository)
    : super(const CategoriesState.initial());

  Future<void> loadCategories() async {
    try {
      emit(const CategoriesState.loading());
      final categories = await _categoriesRepository.getCategories();
      emit(
        CategoriesState.loaded(
          allCategories: categories,
          filteredCategories: categories,
        ),
      );
    } catch (e) {
      emit(CategoriesState.error(e.toString()));
    }
  }

  void search(String query) {
    if (state is! CategoriesLoaded) return;
    final currentState = state as CategoriesLoaded;

    if (query.isEmpty) {
      emit(
        currentState.copyWith(filteredCategories: currentState.allCategories),
      );
      return;
    }

    final fuse = Fuzzy<Category>(
      currentState.allCategories,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'name',
            getter: (category) => category.name,
            weight: 1,
          ),
        ],
      ),
    );

    final results = fuse.search(query);
    final filteredCategories = results.map((r) => r.item).toList();
    emit(currentState.copyWith(filteredCategories: filteredCategories));
  }
}
