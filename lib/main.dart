import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fintamer/src/core/router/app_router.dart';
import 'package:fintamer/src/core/theme/app_theme.dart';
import 'package:fintamer/src/data/api/api_client.dart';
import 'package:fintamer/src/data/repositories/api_account_repository.dart';
import 'package:fintamer/src/data/repositories/api_categories_repository.dart';
import 'package:fintamer/src/data/repositories/api_transactions_repository.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/categories_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/main_screen/main_screen.dart';
import 'package:fintamer/src/data/local/db/app_db.dart';
import 'package:fintamer/src/data/local/drift_local_data_source.dart';
import 'package:fintamer/src/data/services/synchronization_service.dart';
import 'package:fintamer/src/features/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(FintamerApp(appDatabase: AppDatabase()));
}

class FintamerApp extends StatelessWidget {
  const FintamerApp({super.key, required this.appDatabase});
  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    final ApiClient apiClient = ApiClient();
    final DriftLocalDataSource localDataSource = DriftLocalDataSource(
      appDatabase,
    );
    final SynchronizationService synchronizationService =
        SynchronizationService(apiClient, appDatabase);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SynchronizationService>(
          create: (context) => synchronizationService,
        ),
        RepositoryProvider<ITransactionsRepository>(
          create:
              (context) => ApiTransactionsRepository(
                apiClient,
                localDataSource,
                appDatabase,
                synchronizationService,
              ),
        ),
        RepositoryProvider<ICategoriesRepository>(
          create:
              (context) => ApiCategoriesRepository(apiClient, localDataSource),
        ),
        RepositoryProvider<IAccountRepository>(
          create: (context) => ApiAccountRepository(apiClient, localDataSource),
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
      home: const SplashScreen(),
      routes: AppRouter.routes,
    );
  }
}
