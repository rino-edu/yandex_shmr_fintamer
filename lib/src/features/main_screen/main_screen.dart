import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fintamer/src/core/network_status/network_status_cubit.dart';
import 'package:fintamer/src/features/account/screens/account_screen.dart';
import 'package:fintamer/src/features/articles/screens/articles_screen.dart';
import 'package:fintamer/src/features/expenses/screens/expenses_screen.dart';
import 'package:fintamer/src/features/incomes/screens/incomes_screen.dart';
import 'package:fintamer/src/features/main_screen/widgets/offline_banner.dart';
import 'package:fintamer/src/features/settings/screens/settings_screen.dart';
import 'package:fintamer/src/core/haptics/haptic_cubit.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ExpensesScreen(),
    IncomesScreen(),
    AccountScreen(),
    ArticlesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (context.read<HapticCubit>().state) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<NetworkStatusCubit, NetworkStatus>(
              builder: (context, state) {
                if (state == NetworkStatus.offline) {
                  return const OfflineBanner();
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Builder(
              builder: (context) {
                return SvgPicture.asset(
                  'assets/icons/outcomes.svg',
                  colorFilter: ColorFilter.mode(
                    IconTheme.of(context).color!,
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
            label: 'Расходы',
          ),
          NavigationDestination(
            icon: Builder(
              builder: (context) {
                return SvgPicture.asset(
                  'assets/icons/incomes.svg',
                  colorFilter: ColorFilter.mode(
                    IconTheme.of(context).color!,
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
            label: 'Доходы',
          ),
          NavigationDestination(
            icon: Builder(
              builder: (context) {
                return SvgPicture.asset(
                  'assets/icons/account.svg',
                  colorFilter: ColorFilter.mode(
                    IconTheme.of(context).color!,
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
            label: 'Счет',
          ),
          NavigationDestination(
            icon: Builder(
              builder: (context) {
                return SvgPicture.asset(
                  'assets/icons/articles.svg',
                  colorFilter: ColorFilter.mode(
                    IconTheme.of(context).color!,
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
            label: 'Статьи',
          ),
          NavigationDestination(
            icon: Builder(
              builder: (context) {
                return SvgPicture.asset(
                  'assets/icons/settings.svg',
                  colorFilter: ColorFilter.mode(
                    IconTheme.of(context).color!,
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
