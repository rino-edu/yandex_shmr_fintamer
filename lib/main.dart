import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fintamer/src/core/router/app_router.dart';
import 'package:fintamer/src/core/theme/app_theme.dart';
import 'package:fintamer/src/data/repositories/mock_categories_repository.dart';
import 'package:fintamer/src/data/repositories/mock_transactions_repository.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/main_screen/main_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const FintamerApp());
}

class FintamerApp extends StatelessWidget {
  const FintamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ITransactionsRepository>(
          create: (context) => MockTransactionsRepository(),
        ),
        RepositoryProvider<ICategoriesRepository>(
          create: (context) => MockCategoriesRepository(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintamer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      routes: AppRouter.routes,
    );
  }
}
