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
          )..fetchTotalBalance(),
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
  late ShakeDetector _shakeDetector;
  StreamSubscription? _accelerometerSubscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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
    _debounce?.cancel();
    _shakeDetector.stopListening();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой счет'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        titleTextStyle: theme.textTheme.titleLarge,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement edit account
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          if (state is AccountLoaded) {
            final amount = double.tryParse(state.account.balance) ?? 0;
            final formattedAmount = NumberFormat(
              "#,##0.00",
              "ru_RU",
            ).format(amount);
            final balance = '$formattedAmount ₽';

            return Column(
              children: [
                Container(
                  color: AppColors.secondaryColor,
                  child: Column(
                    children: [
                      AnimatedSpoiler(
                        isRevealed: state.isBalanceVisible,
                        child: ListTile(
                          leading: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Text('💰', style: TextStyle(fontSize: 16)),
                          ),
                          title: Text(
                            'Баланс',
                            style: theme.textTheme.bodyLarge,
                          ),
                          trailing: Text(
                            balance,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      if (!state.isBalanceVisible)
                        ListTile(
                          leading: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Text('💰', style: TextStyle(fontSize: 16)),
                          ),
                          title: Text(
                            'Баланс скрыт',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text('Валюта', style: theme.textTheme.bodyLarge),
                        trailing: Text(
                          state.account.currency,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
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
