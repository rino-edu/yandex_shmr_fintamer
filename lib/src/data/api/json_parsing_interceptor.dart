import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';

import 'json_parser.dart';

class JsonParsingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // We only want to parse successful responses with data
    if (response.data == null || response.statusCode != 200) {
      return handler.next(response);
    }

    final path = response.requestOptions.path;
    String? parseType;

    // Determine the type of object to parse based on the request path
    if (path.startsWith('/accounts') && !path.contains('/history')) {
      if (path.split('/').length > 2 &&
          int.tryParse(path.split('/')[2]) != null) {
        parseType = 'AccountResponse';
      } else {
        parseType = 'List<Account>';
      }
    } else if (path.startsWith('/categories')) {
      parseType = 'List<Category>';
    } else if (path.startsWith('/transactions')) {
      parseType = 'List<TransactionResponse>';
    }

    if (parseType != null) {
      // Execute parsing in a separate isolate
      final parsedData = await workerManager.execute(
        () => parseJsonInBackground({'type': parseType, 'data': response.data}),
      );

      // Create a new response with the parsed data
      final newResponse = Response(
        requestOptions: response.requestOptions,
        data: parsedData,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: response.headers,
        extra: response.extra,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
      );
      return handler.next(newResponse);
    }

    // If no specific type matched, pass the original response
    return handler.next(response);
  }
}
