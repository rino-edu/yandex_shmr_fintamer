import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorCubit extends Cubit<Color> {
  ColorCubit() : super(const Color(0xFF2AE881)) {
    _loadColor();
  }

  static const String _colorKey = 'primary_color';

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      emit(Color(colorValue));
    }
  }

  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    emit(color);
  }
}
