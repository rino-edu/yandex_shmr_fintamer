import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/transactions_list/cubit/transactions_list_cubit.dart';
import 'package:intl/intl.dart';

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
    final numberFormatter = NumberFormat("#,##0", "ru_RU");

    return BlocProvider(
      create:
          (context) => TransactionsListCubit(
            transactionsRepository: context.read<ITransactionsRepository>(),
          )..loadTransactions(isIncome: isIncome),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          titleTextStyle: theme.textTheme.titleLarge,
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
                    color: AppColors.secondaryColor,
                    padding: const EdgeInsets.all(
                      AppDimensions.scaffoldPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Всего', style: theme.textTheme.bodyLarge),
                        Text(
                          '${numberFormatter.format(state.totalAmount.round())} ₽',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFFEF7FF)),
                              bottom: BorderSide(color: Color(0xFFFEF7FF)),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.secondaryColor,
                              child: Text(
                                transaction.category.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            title: Text(
                              transaction.category.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              transaction.comment ?? 'Без комментария',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.unselectedNavIcon,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${numberFormatter.format(double.parse(transaction.amount))} ₽',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0x4D3C3C43),
                                  size: 16,
                                ),
                              ],
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
          shape: const CircleBorder(),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: AppColors.white, size: 32,),
        ),
      ),
    );
  }
}
