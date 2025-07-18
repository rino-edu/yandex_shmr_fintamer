import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

enum BiometricStatus { unknown, available, unavailable }

class AuthState {
  final AuthStatus authStatus;
  final BiometricStatus biometricStatus;
  final bool isBiometricEnabled;
  final bool hasPin;

  AuthState({
    this.authStatus = AuthStatus.unknown,
    this.biometricStatus = BiometricStatus.unknown,
    this.isBiometricEnabled = false,
    this.hasPin = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    BiometricStatus? biometricStatus,
    bool? isBiometricEnabled,
    bool? hasPin,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      biometricStatus: biometricStatus ?? this.biometricStatus,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      hasPin: hasPin ?? this.hasPin,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  static const _pinKey = 'user_pin';
  static const _biometricKey = 'biometric_enabled';

  AuthCubit() : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final hasPin = await _storage.read(key: _pinKey) != null;
    final isBiometricEnabled =
        await _storage.read(key: _biometricKey) == 'true';
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final biometricStatus =
        canCheckBiometrics
            ? BiometricStatus.available
            : BiometricStatus.unavailable;

    emit(
      state.copyWith(
        hasPin: hasPin,
        isBiometricEnabled: isBiometricEnabled,
        biometricStatus: biometricStatus,
        authStatus:
            hasPin ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      ),
    );

    if (hasPin && isBiometricEnabled && canCheckBiometrics) {
      authenticateWithBiometrics();
    }
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    emit(state.copyWith(hasPin: true, authStatus: AuthStatus.authenticated));
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    if (storedPin == pin) {
      emit(state.copyWith(authStatus: AuthStatus.authenticated));
      return true;
    }
    return false;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.write(key: _biometricKey, value: 'false');
    emit(
      state.copyWith(
        hasPin: false,
        isBiometricEnabled: false,
        authStatus: AuthStatus.authenticated,
      ),
    );
  }

  Future<void> toggleBiometrics(bool enable) async {
    await _storage.write(key: _biometricKey, value: enable.toString());
    emit(state.copyWith(isBiometricEnabled: enable));
    if (enable) {
      authenticateWithBiometrics();
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Пожалуйста, отсканируйте палец или лицо для входа',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (isAuthenticated) {
        emit(state.copyWith(authStatus: AuthStatus.authenticated));
      }
    } catch (e) {
      // Handle error
    }
  }

  void logout() {
    emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
  }
}
