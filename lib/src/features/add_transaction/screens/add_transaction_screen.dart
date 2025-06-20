import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/models/account_brief.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/add_transaction/cubit/add_transaction_cubit.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatelessWidget {
  final bool isIncome;
  final TransactionResponse? transaction;

  const AddTransactionScreen({
    super.key,
    required this.isIncome,
    this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => AddTransactionCubit(
            transactionsRepository: context.read<ITransactionsRepository>(),
            accountRepository: context.read<IAccountRepository>(),
            isIncome: isIncome,
            transaction: transaction,
          ),
      child: _AddTransactionView(isIncome: isIncome),
    );
  }
}

class _AddTransactionView extends StatelessWidget {
  const _AddTransactionView({required this.isIncome});

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AddTransactionCubit>();

    return BlocListener<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        if (state.status == AddTransactionStatus.success) {
          Navigator.of(context).pop(true);
        }
        if (state.status == AddTransactionStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Произошла ошибка')),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            isIncome ? 'Мои доходы' : 'Мои расходы',
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => cubit.saveTransaction(),
            ),
          ],
        ),
        body: BlocBuilder<AddTransactionCubit, AddTransactionState>(
          builder: (context, state) {
            if (state.status == AddTransactionStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.scaffoldPadding),
              child: Column(
                children: [
                  _CustomListTile(
                    title: 'Счет',
                    trailing: state.selectedAccount?.name ?? 'Загрузка...',
                    onTap: () async {
                      if (state.accounts.isEmpty) return;
                      final selectedAccount =
                          await showModalBottomSheet<AccountBrief>(
                            context: context,
                            builder:
                                (_) => _AccountSelectionSheet(
                                  accounts: state.accounts,
                                ),
                          );
                      if (selectedAccount != null) {
                        cubit.onAccountSelected(selectedAccount);
                      }
                    },
                  ),
                  _CustomListTile(
                    title: 'Категория',
                    trailing: state.category?.name ?? 'Выберите категорию',
                    onTap: () {
                      // TODO: Implement category selection
                    },
                  ),
                  _CustomListTile(
                    title: 'Сумма',
                    trailing: '${state.amount} ₽',
                    onTap: () {
                      // TODO: Implement amount entry
                    },
                  ),
                  _CustomListTile(
                    title: 'Дата',
                    trailing:
                        state.date != null
                            ? DateFormat('dd.MM.yyyy').format(state.date!)
                            : '',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.date ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        cubit.onDateChanged(date);
                      }
                    },
                  ),
                  _CustomListTile(
                    title: 'Время',
                    trailing:
                        state.date != null
                            ? DateFormat('HH:mm').format(state.date!)
                            : '',
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          state.date ?? DateTime.now(),
                        ),
                      );
                      if (time != null) {
                        cubit.onTimeChanged(time);
                      }
                    },
                  ),
                  _CustomListTile(
                    title: 'Комментарий',
                    trailing: state.comment ?? 'Нажмите чтобы добавить',
                    onTap: () {
                      // TODO: Implement comment entry
                    },
                  ),
                  if (state.isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: TextButton(
                        onPressed: () => cubit.deleteTransaction(),
                        child: Text(
                          isIncome ? 'Удалить доход' : 'Удалить расход',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback onTap;

  const _CustomListTile({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFFEF7FF)),
          bottom: BorderSide(color: Color(0xFFFEF7FF)),
        ),
      ),
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodyLarge),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.unselectedNavIcon,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0x4D3C3C43),
              size: 16,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AccountSelectionSheet extends StatelessWidget {
  final List<AccountBrief> accounts;

  const _AccountSelectionSheet({required this.accounts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return ListTile(
          title: Text(account.name),
          onTap: () {
            Navigator.of(context).pop(account);
          },
        );
      },
    );
  }
}
