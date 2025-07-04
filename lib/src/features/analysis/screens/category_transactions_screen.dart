import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/features/add_transaction/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryName;
  final List<TransactionResponse> transactions;
  final bool isIncome;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryName,
    required this.transactions,
    required this.isIncome,
  });

  @override
  State<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends State<CategoryTransactionsScreen> {
  late List<TransactionResponse> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = NumberFormat("#,##0.00", "ru_RU");
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFCAC4D0)),
                bottom: BorderSide(color: Color(0xFFCAC4D0)),
              ),
            ),
            child: ListTile(
              onTap: () async {
                final result = await showModalBottomSheet<bool>(
                  useSafeArea: true,
                  context: context,
                  isScrollControlled: true,
                  builder:
                      (_) => AddTransactionScreen(
                        isIncome: widget.isIncome,
                        transaction: transaction,
                      ),
                );

                if (result == true) {
                  // This is a simplification. A real app would re-fetch.
                  // For now, we just pop, and the analysis screen will have the old data
                  // but a full refresh would be better.
                  // Since we cannot refetch from here, we pop.
                  // The parent will need to refresh itself.
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
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
              subtitle:
                  transaction.comment != null
                      ? Text(
                        transaction.comment!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.unselectedNavIcon,
                        ),
                      )
                      : null,
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
