import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticCubit extends Cubit<bool> {
  HapticCubit() : super(false) {
    _loadHapticPreference();
  }

  static const String _hapticKey = 'haptic_feedback_enabled';

  Future<void> _loadHapticPreference() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool(_hapticKey) ?? false);
  }

  Future<void> setHapticPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, isEnabled);
    emit(isEnabled);
  }
}
