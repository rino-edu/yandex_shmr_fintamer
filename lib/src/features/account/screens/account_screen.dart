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
  late final List<TextEditingController> _controllers;
  late ShakeDetector _shakeDetector;
  StreamSubscription? _accelerometerSubscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        _toggleBalanceWithDebounce();
      },
    );

    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    _debounce?.cancel();
    _shakeDetector.stopListening();
    _accelerometerSubscription?.cancel();
    super.dispose();
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
      // Manage controllers
      _controllers.forEach((c) => c.dispose());
      _controllers.clear();
      for (var account in state.accounts) {
        _controllers.add(TextEditingController(text: account.name));
      }

      return ListView.builder(
        itemCount: state.accounts.length,
        itemBuilder: (context, index) {
          final account = state.accounts[index];
          final controller = _controllers[index];

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
                      state.isEditing
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
