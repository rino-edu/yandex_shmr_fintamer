import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fintamer/src/core/network_status/network_status_cubit.dart';
import 'package:fintamer/src/core/router/app_router.dart';
import 'package:fintamer/src/core/theme/app_theme.dart';
import 'package:fintamer/src/core/theme/cubit/theme_cubit.dart';
import 'package:fintamer/src/core/theme/cubit/color_cubit.dart';
import 'package:fintamer/src/core/haptics/haptic_cubit.dart';
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
import 'package:worker_manager/worker_manager.dart';
import 'package:provider/provider.dart';
import 'package:fintamer/src/features/auth/cubit/auth_cubit.dart';
import 'package:fintamer/src/features/auth/screens/pin_code_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await workerManager.init();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<NetworkStatusCubit>(
          create: (context) => NetworkStatusCubit(),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<ColorCubit>(create: (context) => ColorCubit()),
        BlocProvider<HapticCubit>(create: (context) => HapticCubit()),
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
      ],
      child: MultiRepositoryProvider(
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
                  context.read<NetworkStatusCubit>(),
                ),
          ),
          RepositoryProvider<ICategoriesRepository>(
            create:
                (context) => ApiCategoriesRepository(
                  apiClient,
                  localDataSource,
                  context.read<NetworkStatusCubit>(),
                ),
          ),
          RepositoryProvider<IAccountRepository>(
            create:
                (context) => ApiAccountRepository(
                  apiClient,
                  localDataSource,
                  context.read<NetworkStatusCubit>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: 'Fintamer',
          builder: (context, child) {
            final color = context.watch<ColorCubit>().state;
            final themeMode = context.watch<ThemeCubit>().state;
            ThemeData theme;
            switch (themeMode) {
              case ThemeMode.light:
                theme = AppTheme.lightTheme(color);
                break;
              case ThemeMode.dark:
                theme = AppTheme.darkTheme(color);
                break;
              case ThemeMode.system:
                final brightness = MediaQuery.of(context).platformBrightness;
                theme =
                    brightness == Brightness.dark
                        ? AppTheme.darkTheme(color)
                        : AppTheme.lightTheme(color);
                break;
            }
            return Theme(data: theme, child: child!);
          },
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.authStatus == AuthStatus.authenticated) {
                return const MainScreen();
              }
              if (state.authStatus == AuthStatus.unauthenticated) {
                return const PinCodeScreen(mode: PinCodeMode.enter);
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}
