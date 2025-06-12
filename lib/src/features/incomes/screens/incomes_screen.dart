import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  static const String routeName = '/incomes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Доходы'),
      ),
      body: const Center(child: Text('Доходы')),
    );
  }
}
