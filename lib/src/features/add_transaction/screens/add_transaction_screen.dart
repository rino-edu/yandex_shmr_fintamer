import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
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
            categoriesRepository: context.read<ICategoriesRepository>(),
            isIncome: isIncome,
            transaction: transaction,
          ),
      child: _AddTransactionView(isIncome: isIncome),
    );
  }
}

class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView({required this.isIncome});

  final bool isIncome;

  @override
  _AddTransactionViewState createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<_AddTransactionView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<String> _validateFields(AddTransactionState state) {
    final errors = <String>[];

    if (state.amount.isEmpty || state.amount == '0' || state.amount == '') {
      errors.add('Сумма');
    }

    if (state.category == null) {
      errors.add('Категория');
    }

    return errors;
  }

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
            widget.isIncome ? 'Мои доходы' : 'Мои расходы',
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<AddTransactionCubit, AddTransactionState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    final validationErrors = _validateFields(state);
                    if (validationErrors.isNotEmpty) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Пожалуйста, заполните следующие поля:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...validationErrors.map(
                                  (error) => Text('• $error'),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 4),
                            backgroundColor: Colors.orange,
                          ),
                        );
                    } else {
                      cubit.saveTransaction();
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AddTransactionCubit, AddTransactionState>(
          builder: (context, state) {
            if (state.status == AddTransactionStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  _CustomListTile(
                    title: 'Счет',
                    trailing: state.selectedAccount?.name ?? 'Загрузка...',
                    arrow: true,
                    onTap: () async {
                      if (state.accounts.isEmpty) return;
                      final selectedAccount =
                          await showModalBottomSheet<Account>(
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
                    arrow: true,
                    onTap: () async {
                      if (state.categories.isEmpty) return;
                      final selectedCategory =
                          await showModalBottomSheet<Category>(
                            context: context,
                            builder:
                                (_) => _CategorySelectionSheet(
                                  categories: state.categories,
                                ),
                          );
                      if (selectedCategory != null) {
                        cubit.onCategorySelected(selectedCategory);
                      }
                    },
                  ),
                  Container(
                    height: 70,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFCAC4D0)),
                        bottom: BorderSide(color: Color(0xFFCAC4D0)),
                      ),
                    ),
                    child: ListTile(
                      title: Text('Сумма', style: theme.textTheme.bodyLarge),
                      trailing: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: _amountController..text = state.amount,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.unselectedNavIcon,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Введите сумму",
                            border: InputBorder.none,
                            suffixText: '₽',
                            suffixStyle: TextStyle(
                              color: AppColors.unselectedNavIcon,
                            ),
                          ),
                          onChanged: (value) {
                            // Разрешаем только цифры и одну точку
                            if (value.isEmpty ||
                                RegExp(r'^\d*\.?\d{0,1}$').hasMatch(value)) {
                              cubit.onAmountChanged(
                                value.isEmpty ? '0' : value,
                              );
                            } else {
                              // Если введен недопустимый символ, возвращаем предыдущее значение
                              _amountController.text = state.amount;
                              _amountController
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: _amountController.text.length,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  _CustomListTile(
                    title: 'Дата',
                    arrow: false,
                    trailing:
                        state.date != null
                            ? DateFormat('dd.MM.yyyy').format(state.date!)
                            : '',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.date ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        cubit.onDateChanged(date);
                      }
                    },
                  ),
                  _CustomListTile(
                    title: 'Время',
                    arrow: false,
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
                    arrow: false,
                    trailing: state.comment ?? 'Добавить',
                    onTap: () async {
                      final newComment = await Navigator.of(
                        context,
                      ).push<String>(
                        MaterialPageRoute(
                          builder:
                              (_) => _CommentEditScreen(
                                initialComment: state.comment,
                              ),
                        ),
                      );
                      if (newComment != null) {
                        cubit.onCommentChanged(newComment);
                      }
                    },
                  ),
                  if (state.isEditing)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () => cubit.deleteTransaction(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          backgroundColor: Colors.red, // Красный фон
                          foregroundColor: Colors.white, // Белый текст
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Закруглённые края
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        child: Text(
                          widget.isIncome ? 'Удалить доход' : 'Удалить расход',
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
  final bool arrow;

  const _CustomListTile({
    required this.title,
    required this.trailing,
    required this.onTap,
    required this.arrow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFCAC4D0)),
          bottom: BorderSide(color: Color(0xFFCAC4D0)),
        ),
      ),
      child: ListTile(
        minTileHeight: 70,
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
            if (arrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0x4D3C3C43),
                size: 16,
              )
            else
              const SizedBox(width: 1),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AccountSelectionSheet extends StatelessWidget {
  const _AccountSelectionSheet({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return ListTile(
          title: Text(account.name),
          onTap: () => Navigator.of(context).pop(account),
        );
      },
    );
  }
}

class _CategorySelectionSheet extends StatelessWidget {
  final List<Category> categories;

  const _CategorySelectionSheet({required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.secondaryColor,
            child: Text(category.emoji, style: const TextStyle(fontSize: 16)),
          ),
          title: Text(category.name),
          onTap: () {
            Navigator.of(context).pop(category);
          },
        );
      },
    );
  }
}

class _CommentEditScreen extends StatefulWidget {
  final String? initialComment;

  const _CommentEditScreen({this.initialComment});

  @override
  _CommentEditScreenState createState() => _CommentEditScreenState();
}

class _CommentEditScreenState extends State<_CommentEditScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Комментарий'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'Введите комментарий...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
