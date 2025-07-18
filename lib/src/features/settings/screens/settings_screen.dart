import 'package:fintamer/src/core/theme/cubit/color_cubit.dart';
import 'package:fintamer/src/core/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fintamer/src/core/haptics/haptic_cubit.dart';
import 'package:flutter/services.dart';
import 'package:fintamer/src/features/auth/cubit/auth_cubit.dart';
import 'package:fintamer/src/features/auth/screens/pin_code_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              bool isDarkMode;
              if (state == ThemeMode.system) {
                isDarkMode =
                    MediaQuery.of(context).platformBrightness ==
                    Brightness.dark;
              } else {
                isDarkMode = state == ThemeMode.dark;
              }

              /*                return ListTile(
                title: const Text('Темная тема'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    final newTheme = value ? ThemeMode.dark : ThemeMode.light;
                    context.read<ThemeCubit>().setTheme(newTheme);
                  },
                ),
              );*/
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFCAC4D0)),
                    bottom: BorderSide(color: Color(0xFFCAC4D0)),
                  ),
                ),
                child: ListTile(
                  minTileHeight: 56,
                  title: Text(
                    'Темная тема',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      final newTheme = value ? ThemeMode.dark : ThemeMode.light;
                      context.read<ThemeCubit>().setTheme(newTheme);
                    },
                  ),
                  onTap: null,
                ),
              );
            },
          ),
          BlocBuilder<ColorCubit, Color>(
            builder: (context, color) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFCAC4D0))),
                ),
                child: ListTile(
                  minTileHeight: 56,
                  title: Text(
                    'Основной цвет',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: CircleAvatar(backgroundColor: color, radius: 14),
                  onTap: () {
                    Color pickerColor = color;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Выберите цвет'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: (newColor) {
                                pickerColor = newColor;
                              },
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Готово'),
                              onPressed: () {
                                context.read<ColorCubit>().setColor(
                                  pickerColor,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          BlocBuilder<HapticCubit, bool>(
            builder: (context, isHapticEnabled) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFCAC4D0))),
                ),
                child: ListTile(
                  minTileHeight: 56,
                  title: Text(
                    'Тактильный отклик',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: Switch(
                    value: isHapticEnabled,
                    onChanged: (value) {
                      context.read<HapticCubit>().setHapticPreference(value);
                      if (value) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                  ),
                  onTap: null,
                ),
              );
            },
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFCAC4D0)),
                      ),
                    ),
                    child: ListTile(
                      minTileHeight: 56,
                      title: Text(
                        authState.hasPin
                            ? 'Изменить ПИН-код'
                            : 'Установить ПИН-код',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    const PinCodeScreen(mode: PinCodeMode.set),
                          ),
                        );
                      },
                    ),
                  ),
                  if (authState.hasPin)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFCAC4D0)),
                        ),
                      ),
                      child: ListTile(
                        minTileHeight: 56,
                        title: Text(
                          'Удалить ПИН-код',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                        ),
                        onTap: () => context.read<AuthCubit>().removePin(),
                      ),
                    ),
                  if (authState.biometricStatus == BiometricStatus.available &&
                      authState.hasPin)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFCAC4D0)),
                        ),
                      ),
                      child: ListTile(
                        minTileHeight: 56,
                        title: Text(
                          'Вход по Face ID/Touch ID',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Switch(
                          value: authState.isBiometricEnabled,
                          onChanged: (value) {
                            context.read<AuthCubit>().toggleBiometrics(value);
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
