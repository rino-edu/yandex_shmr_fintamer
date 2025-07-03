import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/features/articles/cubit/categories_cubit.dart';
import 'package:fintamer/src/features/articles/cubit/categories_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  static const String routeName = '/articles';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CategoriesCubit(context.read<ICategoriesRepository>())
                ..loadCategories(),
      child: const _ArticlesView(),
    );
  }
}

class _ArticlesView extends StatefulWidget {
  const _ArticlesView();

  @override
  State<_ArticlesView> createState() => _ArticlesViewState();
}

class _ArticlesViewState extends State<_ArticlesView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<CategoriesCubit>().search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Мои статьи'),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesInitial) {
            return const SizedBox.shrink();
          } else if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesError) {
            return Center(child: Text(state.message));
          } else if (state is CategoriesLoaded) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECE6F0),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFCAC4D0)),
                      top: BorderSide(color: Color(0xFFECE6F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Найти статью',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.search, color: Color(0xFF49454F)),
                      ),
                    ],
                  ),
                ),
                if (state.filteredCategories.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Категории не найдены')),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = state.filteredCategories[index];
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFCAC4D0)),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.secondaryColor,
                              child: Text(
                                category.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
