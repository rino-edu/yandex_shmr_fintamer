import 'package:flutter/material.dart';
import 'package:fintamer/src/features/transactions_list/screens/transactions_list_screen.dart';

class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionsListScreen(isIncome: true, title: 'Доходы сегодня');
  }
}
