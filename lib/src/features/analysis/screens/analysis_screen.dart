import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/analysis/cubit/analysis_cubit.dart';
import 'package:fintamer/src/features/analysis/cubit/analysis_state.dart';
import 'package:fintamer/src/features/analysis/screens/category_transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  final bool isIncome;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalysisScreen({
    super.key,
    required this.isIncome,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => AnalysisCubit(
            transactionsRepository: context.read<ITransactionsRepository>(),
            accountRepository: context.read<IAccountRepository>(),
          )..loadAnalysis(
            isIncome: isIncome,
            startDate: startDate,
            endDate: endDate,
          ),
      child: _AnalysisView(isIncome: isIncome),
    );
  }
}

class _AnalysisView extends StatelessWidget {
  const _AnalysisView({required this.isIncome});
  final bool isIncome;

  Future<void> _selectDate(
    BuildContext context,
    bool isStartDate,
    DateTime initialDate,
  ) async {
    final cubit = context.read<AnalysisCubit>();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = NumberFormat("#,##0", "ru_RU");
    final dateFormatter = DateFormat('dd.MM.yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Анализ'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        titleTextStyle: theme.textTheme.titleLarge,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AnalysisCubit, AnalysisState>(
        builder: (context, state) {
          if (state is AnalysisInitial || state is AnalysisLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalysisError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else if (state is AnalysisLoaded) {
            return Column(
              children: [
                _buildPeriodRow(
                  context: context,
                  label: 'Период: начало',
                  date: state.startDate,
                  onTap: () => _selectDate(context, true, state.startDate),
                  formatter: dateFormatter,
                ),
                const Divider(height: 1, thickness: 1),
                _buildPeriodRow(
                  context: context,
                  label: 'Период: конец',
                  date: state.endDate,
                  onTap: () => _selectDate(context, false, state.endDate),
                  formatter: dateFormatter,
                ),
                const Divider(height: 1, thickness: 1),
                _buildTotalRow(
                  context: context,
                  total: state.totalAmount,
                  formatter: numberFormatter,
                ),
                const Divider(height: 1, thickness: 1),
                if (state.analysisGroups.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Нет данных для анализа')),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.analysisGroups.length,
                      itemBuilder: (context, index) {
                        final group = state.analysisGroups[index];
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFCAC4D0)),
                            ),
                          ),
                          child: ListTile(
                            onTap: () async {
                              final result = await Navigator.of(
                                context,
                              ).push<bool>(
                                MaterialPageRoute(
                                  builder:
                                      (_) => CategoryTransactionsScreen(
                                        categoryName: group.category.name,
                                        transactions: group.transactions,
                                        isIncome: isIncome,
                                      ),
                                ),
                              );

                              if (result == true && context.mounted) {
                                context.read<AnalysisCubit>().loadAnalysis(
                                  isIncome: isIncome,
                                  startDate: state.startDate,
                                  endDate: state.endDate,
                                );
                              }
                            },
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.secondaryColor,
                              child: Text(
                                group.category.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            title: Text(
                              group.category.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            subtitle:
                                group.latestComment != null
                                    ? Text(
                                      group.latestComment!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppColors.unselectedNavIcon,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                    : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${group.percentage.toStringAsFixed(2)}%',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Text(
                                      '${numberFormatter.format(group.sum)} ₽',
                                      style: theme.textTheme.bodyLarge,
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
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xff2AE881),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                formatter.format(date),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(AppDimensions.scaffoldPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Сумма', style: theme.textTheme.bodyLarge),
          Text(
            '${formatter.format(total.round())} ₽',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
