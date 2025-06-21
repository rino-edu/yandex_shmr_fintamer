import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/models/account_brief.dart';
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
              child: Column(
                children: [
                  _CustomListTile(
                    title: 'Счет',
                    trailing: state.selectedAccount?.name ?? 'Загрузка...',
                    arrow: true,
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
                  _CustomListTile(
                    title: 'Сумма',
                    arrow: false,
                    trailing: '${state.amount} ₽',
                    onTap: () async {
                      final newAmount = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (_) => _AmountKeyboard(initialValue: state.amount),
                      );
                      if (newAmount != null) {
                        cubit.onAmountChanged(newAmount);
                      }
                    },
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
                        lastDate: DateTime(2100),
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
                    trailing: state.comment ?? 'Нажмите чтобы добавить',
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
            arrow
                ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0x4D3C3C43),
                  size: 16,
                )
                : SizedBox(width: 1),
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

class _AmountKeyboard extends StatefulWidget {
  final String initialValue;

  const _AmountKeyboard({required this.initialValue});

  @override
  _AmountKeyboardState createState() => _AmountKeyboardState();
}

class _AmountKeyboardState extends State<_AmountKeyboard> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue == '0' ? '' : widget.initialValue;
  }

  void _onTap(String char) {
    setState(() {
      if (char == '⌫') {
        if (_value.isNotEmpty) {
          _value = _value.substring(0, _value.length - 1);
        }
      } else if (char == '.' && !_value.contains('.')) {
        _value += char;
      } else if (char != '.') {
        _value += char;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_value.isEmpty ? '0' : _value} ₽',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const Divider(height: 1),
          Table(
            children: [
              TableRow(children: ['1', '2', '3'].map(_buildButton).toList()),
              TableRow(children: ['4', '5', '6'].map(_buildButton).toList()),
              TableRow(children: ['7', '8', '9'].map(_buildButton).toList()),
              TableRow(children: ['.', '0', '⌫'].map(_buildButton).toList()),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('Готово'),
                onPressed: () => Navigator.of(context).pop(_value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String char) {
    return AspectRatio(
      aspectRatio: 2,
      child: TextButton(
        child: Text(char, style: const TextStyle(fontSize: 24)),
        onPressed: () => _onTap(char),
      ),
    );
  }
}
