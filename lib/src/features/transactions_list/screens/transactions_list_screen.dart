import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/transactions_list/cubit/transactions_list_cubit.dart';

class TransactionsListScreen extends StatelessWidget {
  final bool isIncome;
  final String title;

  const TransactionsListScreen({
    super.key,
    required this.isIncome,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create:
          (context) => TransactionsListCubit(
            transactionsRepository: context.read<ITransactionsRepository>(),
          )..loadTransactions(isIncome: isIncome),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.primaryColor,
          titleTextStyle: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // TODO: Navigate to history screen
              },
            ),
          ],
        ),
        body: BlocBuilder<TransactionsListCubit, TransactionsListState>(
          builder: (context, state) {
            if (state is TransactionsListInitial ||
                state is TransactionsListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionsListError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            } else if (state is TransactionsListLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(child: Text('Операций за сегодня нет'));
              }
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainer,
                    padding: const EdgeInsets.all(
                      AppDimensions.scaffoldPadding,
                    ),
                    child: Text(
                      'Всего: ${state.totalAmount.toStringAsFixed(2)} ₽',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(
                        AppDimensions.scaffoldPadding / 2,
                      ),
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        final amountColor =
                            transaction.category.isIncome
                                ? AppColors.incomeColor
                                : AppColors.expenseColor;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                transaction.category.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            title: Text(
                              transaction.category.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              transaction.comment ?? 'Без комментария',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              '${transaction.category.isIncome ? '+' : '-'} ${transaction.amount} ₽',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                              ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add transaction screen
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }
}
