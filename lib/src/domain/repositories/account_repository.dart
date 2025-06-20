import 'package:fintamer/src/domain/models/account.dart';
import 'package:fintamer/src/domain/models/account_response.dart';
import 'package:fintamer/src/domain/models/requests/account_update_request.dart';

abstract class IAccountRepository {
  Future<AccountResponse> getAccount({required int id});

  Future<Account> updateAccount({
    required int id,
    required AccountUpdateRequest request,
  });
}
