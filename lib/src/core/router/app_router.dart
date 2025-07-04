import 'package:fintamer/src/features/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:fintamer/src/features/account/screens/account_screen.dart';
import 'package:fintamer/src/features/articles/screens/articles_screen.dart';
import 'package:fintamer/src/features/expenses/screens/expenses_screen.dart';
import 'package:fintamer/src/features/incomes/screens/incomes_screen.dart';
import 'package:fintamer/src/features/settings/screens/settings_screen.dart';

abstract class AppRouter {
  static const String expenses = '/expenses';
  static const String incomes = '/incomes';
  static const String account = '/account';
  static const String articles = '/articles';
  static const String settings = '/settings';
  static const String mainScreen = '/main';

  static String initialRoute = expenses;

  static final Map<String, WidgetBuilder> routes = {
    expenses: (_) => const ExpensesScreen(),
    incomes: (_) => const IncomesScreen(),
    account: (_) => const AccountScreen(),
    articles: (_) => const ArticlesScreen(),
    settings: (_) => const SettingsScreen(),
    mainScreen: (_) => const MainScreen(),
  };
}
