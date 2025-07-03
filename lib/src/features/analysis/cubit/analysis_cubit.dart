import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';
import 'package:fintamer/src/domain/repositories/account_repository.dart';
import 'package:fintamer/src/domain/repositories/transactions_repository.dart';
import 'package:fintamer/src/features/analysis/cubit/analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  final ITransactionsRepository _transactionsRepository;
  final IAccountRepository _accountRepository;

  AnalysisCubit({
    required ITransactionsRepository transactionsRepository,
    required IAccountRepository accountRepository,
  }) : _transactionsRepository = transactionsRepository,
       _accountRepository = accountRepository,
       super(AnalysisInitial());

  Future<void> updateStartDate({
    required DateTime startDate,
    required bool isIncome,
  }) async {
    if (state is AnalysisLoaded) {
      final currentState = state as AnalysisLoaded;
      await loadAnalysis(
        startDate: startDate,
        endDate: currentState.endDate,
        isIncome: isIncome,
      );
    }
  }

  Future<void> updateEndDate({
    required DateTime endDate,
    required bool isIncome,
  }) async {
    if (state is AnalysisLoaded) {
      final currentState = state as AnalysisLoaded;
      await loadAnalysis(
        startDate: currentState.startDate,
        endDate: endDate,
        isIncome: isIncome,
      );
    }
  }

  Future<void> loadAnalysis({
    DateTime? startDate,
    DateTime? endDate,
    required bool isIncome,
  }) async {
    try {
      emit(AnalysisLoading());

      final finalStartDate =
          startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
      final finalEndDate =
          endDate ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

      final accounts = await _accountRepository.getAccounts();
      final List<TransactionResponse> allTransactions = [];

      for (final account in accounts) {
        final transactions = await _transactionsRepository
            .getTransactionsForPeriod(
              accountId: account.id,
              startDate: finalStartDate,
              endDate: finalEndDate,
            );
        allTransactions.addAll(transactions);
      }

      final filteredTransactions =
          allTransactions
              .where((t) => t.category.isIncome == isIncome)
              .toList();

      if (filteredTransactions.isEmpty) {
        emit(
          AnalysisLoaded(
            analysisGroups: [],
            totalAmount: 0,
            startDate: finalStartDate,
            endDate: finalEndDate,
          ),
        );
        return;
      }

      final totalAmount =
          filteredTransactions.map((t) => double.parse(t.amount)).sum;

      final groupedByCategory = groupBy(
        filteredTransactions,
        (TransactionResponse t) => t.category,
      );

      final List<AnalysisGroup> analysisGroups = [];

      groupedByCategory.forEach((category, transactions) {
        final categorySum = transactions.map((t) => double.parse(t.amount)).sum;
        final percentage =
            totalAmount > 0 ? (categorySum / totalAmount) * 100 : 0.0;

        transactions.sort(
          (a, b) => b.transactionDate.compareTo(a.transactionDate),
        );
        final latestComment = transactions.first.comment;

        analysisGroups.add(
          AnalysisGroup(
            category: category,
            sum: categorySum,
            percentage: percentage,
            latestComment: latestComment,
            transactions: transactions,
          ),
        );
      });

      analysisGroups.sort((a, b) => b.sum.compareTo(a.sum));

      emit(
        AnalysisLoaded(
          analysisGroups: analysisGroups,
          totalAmount: totalAmount,
          startDate: finalStartDate,
          endDate: finalEndDate,
        ),
      );
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }
}
