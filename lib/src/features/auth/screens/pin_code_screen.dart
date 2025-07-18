import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/core/haptics/haptic_cubit.dart';
import 'package:flutter/services.dart';
import 'package:fintamer/src/features/auth/cubit/auth_cubit.dart';

enum PinCodeMode { set, confirm, enter }

class PinCodeScreen extends StatefulWidget {
  final PinCodeMode mode;
  final String? firstPin;

  const PinCodeScreen({super.key, required this.mode, this.firstPin});

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  String _pin = '';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _updateMessage();
  }

  void _updateMessage() {
    switch (widget.mode) {
      case PinCodeMode.set:
        _message = 'Установите 4-значный ПИН-код';
        break;
      case PinCodeMode.confirm:
        _message = 'Подтвердите ваш ПИН-код';
        break;
      case PinCodeMode.enter:
        _message = 'Введите ваш ПИН-код';
        break;
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });
      if (_pin.length == 4) {
        _handlePinEntered();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handlePinEntered() async {
    final authCubit = context.read<AuthCubit>();
    switch (widget.mode) {
      case PinCodeMode.set:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => PinCodeScreen(mode: PinCodeMode.confirm, firstPin: _pin),
          ),
        );
        break;
      case PinCodeMode.confirm:
        if (_pin == widget.firstPin) {
          await authCubit.setPin(_pin);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          _showError('ПИН-коды не совпадают');
        }
        break;
      case PinCodeMode.enter:
        final success = await authCubit.verifyPin(_pin);
        if (!success) {
          _showError('Неверный ПИН-код');
        }
        break;
    }
  }

  void _showError(String message) {
    setState(() {
      _message = message;
      _pin = '';
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _updateMessage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        index < _pin.length
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        if (index == 9) return const SizedBox.shrink(); // Empty space
        if (index == 11) {
          return IconButton(
            icon: const Icon(Icons.backspace_outlined),
            onPressed: _onDeletePressed,
          );
        }
        final number = index == 10 ? '0' : (index + 1).toString();
        return TextButton(
          child: Text(
            number,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          onPressed: () => _onNumberPressed(number),
        );
      },
    );
  }
}
