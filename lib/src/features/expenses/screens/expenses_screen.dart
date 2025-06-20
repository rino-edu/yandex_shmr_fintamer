import 'package:flutter/material.dart';
import 'package:fintamer/src/features/transactions_list/screens/transactions_list_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionsListScreen(isIncome: false, title: 'Расходы');
  }
}
