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
      appBar: AppBar(title: const Text('Счет'), centerTitle: true),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          if (state is AccountLoaded) {
            final balance = NumberFormat.currency(
              locale: 'ru_RU',
              symbol: '₽',
            ).format(double.tryParse(state.account.balance) ?? 0);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.account.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSpoiler(
                        isRevealed: state.isBalanceVisible,
                        child: Text(
                          balance,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!state.isBalanceVisible)
                        Text(
                          'Баланс скрыт',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
                // TODO: Add stats widgets later
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
