import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final String categoryName;
  final List<TransactionResponse> transactions;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryName,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = NumberFormat("#,##0.00", "ru_RU");
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFCAC4D0)),
                bottom: BorderSide(color: Color(0xFFCAC4D0)),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.secondaryColor,
                child: Text(
                  transaction.category.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              title: Text(
                transaction.category.name,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: transaction.comment != null ? Text(
                transaction.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.unselectedNavIcon,
                ),
              ) : null,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${numberFormatter.format(double.parse(transaction.amount))} ₽',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    timeFormatter.format(transaction.transactionDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
