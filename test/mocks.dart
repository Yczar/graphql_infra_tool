import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_auth_provider.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_parser.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

class MockAuthProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'Authorization';

  @override
  TokenCallback get getToken => () async => 'Bearer mock-token';
}

class MockExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final code = rawException.graphqlErrors[0].extensions?['code'];
    if (code != 'CUSTOM_ERROR') return null;

    return AppError(
      AppErrorModel(message: 'Custom handled error', code: 'CUSTOM_ERROR'),
    );
  }
}
