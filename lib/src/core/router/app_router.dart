import 'package:flutter/material.dart';
import 'package:fintamer/src/features/account/screens/account_screen.dart';
import 'package:fintamer/src/features/articles/screens/articles_screen.dart';
import 'package:fintamer/src/features/expenses/screens/expenses_screen.dart';
import 'package:fintamer/src/features/incomes/screens/incomes_screen.dart';
import 'package:fintamer/src/features/settings/screens/settings_screen.dart';

abstract class AppRouter {
  static const String initialRoute = ExpensesScreen.routeName;

  static final Map<String, WidgetBuilder> routes = {
    ExpensesScreen.routeName: (_) => const ExpensesScreen(),
    IncomesScreen.routeName: (_) => const IncomesScreen(),
    AccountScreen.routeName: (_) => const AccountScreen(),
    ArticlesScreen.routeName: (_) => const ArticlesScreen(),
    SettingsScreen.routeName: (_) => const SettingsScreen(),
  };
}
