import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

class AnalysisGroup extends Equatable {
  final Category category;
  final double sum;
  final double percentage;
  final String? latestComment;
  final List<TransactionResponse> transactions;

  const AnalysisGroup({
    required this.category,
    required this.sum,
    required this.percentage,
    this.latestComment,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    category,
    sum,
    percentage,
    latestComment,
    transactions,
  ];
}

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final List<AnalysisGroup> analysisGroups;
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;

  const AnalysisLoaded({
    required this.analysisGroups,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [analysisGroups, totalAmount, startDate, endDate];
}

class AnalysisError extends AnalysisState {
  final String message;

  const AnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
