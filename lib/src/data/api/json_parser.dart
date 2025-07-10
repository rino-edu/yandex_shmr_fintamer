import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/models/category.dart';
import 'package:fintamer/src/domain/models/transaction_response.dart';

// This is a top-level function, as required by worker_manager.
// It acts as a dispatcher to select the correct parsing logic.
dynamic parseJsonInBackground(Map<String, dynamic> args) {
  final String type = args['type'];
  final dynamic data = args['data'];

  switch (type) {
    case 'List<Account>':
      return (data as List<dynamic>)
          .map((json) => Account.fromJson(json))
          .toList();
    case 'AccountResponse':
      return AccountResponse.fromJson(data);
    case 'List<Category>':
      return (data as List<dynamic>)
          .map((json) => Category.fromJson(json))
          .toList();
    case 'List<TransactionResponse>':
      return (data as List<dynamic>)
          .map((json) => TransactionResponse.fromJson(json))
          .toList();
    default:
      // Return data as-is if type is not recognized
      return data;
  }
}
