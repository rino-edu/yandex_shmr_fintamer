import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const String routeName = '/account';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Счет'),
      ),
      body: const Center(child: Text('Счет')),
    );
  }
}
