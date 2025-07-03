import 'dart:async';
import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/features/account/cubit/account_cubit.dart';
import 'package:fintamer/src/features/account/cubit/account_state.dart';
import 'package:fintamer/src/features/account/widgets/animated_spoiler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';
import 'package:intl/intl.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/domain/models/account.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const String routeName = '/account';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => AccountCubit(
            context.read<IAccountRepository>(),
            context.read<ITransactionsRepository>(),
          )..fetchAccounts(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  List<TextEditingController>? _controllers;
  late ShakeDetector _shakeDetector;
  StreamSubscription? _accelerometerSubscription;
  Timer? _debounce;
  bool _wasEditing = false;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        _toggleBalanceWithDebounce();
      },
    );
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (event.z < -9.5) {
        _toggleBalanceWithDebounce();
      }
    });
  }

  void _toggleBalanceWithDebounce() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<AccountCubit>().toggleBalanceVisibility();
      }
    });
  }

  @override
  void dispose() {
    _disposeControllers();
    _debounce?.cancel();
    _shakeDetector.stopListening();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _disposeControllers() {
    if (_controllers != null) {
      for (var c in _controllers!) {
        c.dispose();
      }
      _controllers = null;
    }
  }

  void _initControllers(AccountLoaded state) {
    _disposeControllers();
    _controllers =
        state.accounts.map((account) {
          final initial = state.editedNames[account.id] ?? account.name;
          return TextEditingController(text: initial);
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AccountCubit>();

    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountLoaded && state.saveError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.saveError!),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      builder: (context, state) {
        final isEditing = state is AccountLoaded && state.isEditing;
        if (state is AccountLoaded) {
          if (isEditing && !_wasEditing) {
            _initControllers(state);
            _wasEditing = true;
          } else if (!isEditing && _wasEditing) {
            _disposeControllers();
            _wasEditing = false;
          }
        } else {
          _disposeControllers();
          _wasEditing = false;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Мой счет'),
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            titleTextStyle: theme.textTheme.titleLarge,
            leading:
                isEditing
                    ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => cubit.exitEditMode(),
                    )
                    : null,
            actions: [
              if (state is AccountLoaded)
                isEditing
                    ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed:
                          state.isSaving ? null : () => cubit.saveChanges(),
                    )
                    : IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => cubit.enterEditMode(),
                    ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, Account account) {
    final cubit = context.read<AccountCubit>();
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCurrencyTile(context, '₽', 'Российский рубль ₽', () {
                cubit.changeAccountCurrency(account.id, 'RUB');
                Navigator.pop(bottomSheetContext);
              }),
              _buildCurrencyTile(context, '\$', 'Американский доллар \$', () {
                cubit.changeAccountCurrency(account.id, 'USD');
                Navigator.pop(bottomSheetContext);
              }),
              _buildCurrencyTile(context, '€', 'Евро €', () {
                cubit.changeAccountCurrency(account.id, 'EUR');
                Navigator.pop(bottomSheetContext);
              }),
              _buildCancelTile(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    String leading,
    String title,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 72,
      child: ListTile(
        leading: Text(leading, style: const TextStyle(fontSize: 24)),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCancelTile(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.red,
      height: 72,
      child: ListTile(
        leading: const Icon(Icons.cancel_outlined, color: Colors.white),
        title: const Text('Отмена', style: TextStyle(color: Colors.white)),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AccountState state) {
    final theme = Theme.of(context);
    final cubit = context.read<AccountCubit>();

    if (state is AccountLoading && state is! AccountLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AccountError) {
      return Center(child: Text('Ошибка: ${state.message}'));
    }
    if (state is AccountLoaded) {
      return ListView.builder(
        itemCount: state.accounts.length,
        itemBuilder: (context, index) {
          final account = state.accounts[index];
          final controller =
              state.isEditing && _controllers != null
                  ? _controllers![index]
                  : null;

          final amount = double.tryParse(account.balance) ?? 0;
          final hasFractional =
              (amount.abs() - amount.abs().truncate()) > 0.001;
          final formatPattern = hasFractional ? "#,##0.00" : "#,##0";
          final formattedAmount = NumberFormat(
            formatPattern,
            "ru_RU",
          ).format(amount);

          String getCurrencySymbol(String currencyCode) {
            switch (currencyCode) {
              case 'RUB':
                return '₽';
              case 'USD':
                return '\$';
              case 'EUR':
                return '€';
              default:
                return currencyCode;
            }
          }

          final currencySymbol = getCurrencySymbol(account.currency);
          final balance = '$formattedAmount $currencySymbol';

          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFFEF7FF)),
                    bottom: BorderSide(color: Color(0xFFFEF7FF)),
                  ),
                  color: AppColors.secondaryColor,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Text('💰', style: TextStyle(fontSize: 16)),
                  ),
                  title:
                      state.isEditing && controller != null
                          ? TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: theme.textTheme.titleMedium,
                            onChanged:
                                (value) => cubit.onAccountNameChanged(
                                  account.id,
                                  value,
                                ),
                          )
                          : Text(
                            state.editedNames[account.id] ?? account.name,
                            style: theme.textTheme.titleMedium,
                          ),
                  trailing: SizedBox(
                    width: 150,
                    child: AnimatedSpoiler(
                      isRevealed: state.isBalanceVisible,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(balance, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFFEF7FF)),
                    bottom: BorderSide(color: Color(0xFFFEF7FF)),
                  ),
                  color: AppColors.secondaryColor,
                ),
                child: ListTile(
                  title: Text('Валюта', style: theme.textTheme.bodyLarge),
                  trailing: Text(
                    currencySymbol,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  ),
                  onTap:
                      state.isEditing
                          ? () => _showCurrencyPicker(context, account)
                          : null,
                ),
              ),
            ],
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
