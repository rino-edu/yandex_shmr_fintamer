import 'package:fintamer/src/core/theme/cubit/color_cubit.dart';
import 'package:fintamer/src/core/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
        ],
      ),
    );
  }
}
