import 'package:equatable/equatable.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<TransactionResponse> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String? errorMessage;

  const HistoryState({
    required this.status,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.errorMessage,
  });

  factory HistoryState.initial() {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
    return HistoryState(
      status: HistoryStatus.initial,
      transactions: const [],
      startDate: startDate,
      endDate: endDate,
      totalAmount: 0.0,
    );
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<TransactionResponse>? transactions,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    startDate,
    endDate,
    totalAmount,
    errorMessage,
  ];
}
