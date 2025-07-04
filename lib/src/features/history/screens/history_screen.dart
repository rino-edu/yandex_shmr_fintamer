import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/add_transaction/screens/add_transaction_screen.dart';
import 'package:fintamer/src/features/analysis/screens/analysis_screen.dart';
import 'package:fintamer/src/features/history/cubit/history_cubit.dart';
import 'package:fintamer/src/features/history/cubit/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final bool isIncome;

  const HistoryScreen({super.key, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => HistoryCubit(
            transactionsRepository: context.read<ITransactionsRepository>(),
            accountRepository: context.read<IAccountRepository>(),
          )..loadHistory(isIncome: isIncome),
      child: _HistoryView(isIncome: isIncome),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.isIncome});
  final bool isIncome;

  Future<void> _selectDate(
    BuildContext context,
    bool isStartDate,
    DateTime initialDate,
  ) async {
    final cubit = context.read<HistoryCubit>();
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, now.month, now.day);
    final lastDate = DateTime(now.year + 5, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isStartDate) {
        cubit.updateStartDate(startDate: pickedDate, isIncome: isIncome);
      } else {
        cubit.updateEndDate(endDate: pickedDate, isIncome: isIncome);
      }
    }
  }

  Future<void> _showSortDialog(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Выберите сортировку'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                cubit.updateSortType(
                  sortType: HistorySortType.byDate,
                  isIncome: isIncome,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('По дате'),
            ),
            SimpleDialogOption(
              onPressed: () {
                cubit.updateSortType(
                  sortType: HistorySortType.byAmount,
                  isIncome: isIncome,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('По сумме'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = NumberFormat("#,##0.00", "ru_RU");
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Моя история'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        titleTextStyle: theme.textTheme.titleLarge,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pending_actions),
            onPressed: () {
              final historyState = context.read<HistoryCubit>().state;
              if (historyState.status == HistoryStatus.success) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => AnalysisScreen(
                          isIncome: isIncome,
                          startDate: historyState.startDate,
                          endDate: historyState.endDate,
                        ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.status == HistoryStatus.initial ||
              state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == HistoryStatus.failure) {
            return Center(child: Text('Ошибка: ${state.errorMessage}'));
          } else if (state.status == HistoryStatus.success) {
            return Column(
              children: [
                _buildPeriodRow(
                  context: context,
                  label: 'Начало',
                  date: state.startDate,
                  onTap: () => _selectDate(context, true, state.startDate),
                  formatter: dateFormatter,
                ),
                const Divider(height: 1, thickness: 1),
                _buildPeriodRow(
                  context: context,
                  label: 'Конец',
                  date: state.endDate,
                  onTap: () => _selectDate(context, false, state.endDate),
                  formatter: dateFormatter,
                ),
                const Divider(height: 1, thickness: 1),
                _buildSortRow(
                  context: context,
                  sortType: state.sortType,
                  onTap: () => _showSortDialog(context),
                ),
                const Divider(height: 1, thickness: 1),
                _buildTotalRow(
                  context: context,
                  total: state.totalAmount,
                  formatter: numberFormatter,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFCAC4D0)),
                            bottom: BorderSide(color: Color(0xFFCAC4D0)),
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                              useSafeArea: true,
                              context: context,
                              isScrollControlled: true,
                              builder:
                                  (_) => AddTransactionScreen(
                                    isIncome: isIncome,
                                    transaction: transaction,
                                  ),
                            );
                            if (result == true && context.mounted) {
                              context.read<HistoryCubit>().loadHistory(
                                isIncome: isIncome,
                              );
                            }
                          },
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${numberFormatter.format(double.parse(transaction.amount))} ₽',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  Text(
                                    timeFormatter.format(
                                      transaction.transactionDate,
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
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
    );
  }

  Widget _buildPeriodRow({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required DateFormat formatter,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.secondaryColor,
        padding: const EdgeInsets.all(AppDimensions.scaffoldPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(formatter.format(date), style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow({
    required BuildContext context,
    required HistorySortType sortType,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final sortTypeText =
        sortType == HistorySortType.byDate ? 'По дате' : 'По сумме';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.secondaryColor,
        padding: const EdgeInsets.all(AppDimensions.scaffoldPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Сортировка', style: theme.textTheme.bodyLarge),
            Text(sortTypeText, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow({
    required BuildContext context,
    required double total,
    required NumberFormat formatter,
  }) {
    final theme = Theme.of(context);
    final numberFormatter = NumberFormat("#,##0", "ru_RU");
    return Container(
      width: double.infinity,
      color: AppColors.secondaryColor,
      padding: const EdgeInsets.all(AppDimensions.scaffoldPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Сумма', style: theme.textTheme.bodyLarge),
          Text(
            '${numberFormatter.format(total.round())} ₽',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
