import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  static const String routeName = '/expenses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Расходы'),
      ),
      body: const Center(child: Text('Расходы')),
    );
  }
}
