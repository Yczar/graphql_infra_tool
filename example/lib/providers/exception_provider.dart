import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_parser.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

/// Handles standard HTTP error codes surfaced via GraphQL errors.
class HttpExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final error = rawException.graphqlErrors[0];
    final code = error.extensions?['code'] as String?;
    if (code != 'HTTP_EXCEPTION') return null;

    final status = error.extensions?['status'] as int?;

    final (message, resolvedCode) = switch (status) {
      401 => ('Authentication required. Please log in again.', 'UNAUTHORIZED'),
      403 => ('You do not have permission to perform this action.', 'FORBIDDEN'),
      404 => ('The requested resource was not found.', 'NOT_FOUND'),
      500 => ('Internal server error. Please try again later.', 'INTERNAL_SERVER_ERROR'),
      _ => (error.message, code ?? 'HTTP_EXCEPTION'),
    };

    return AppError(AppErrorModel(message: message, code: resolvedCode));
  }
}

/// Handles resource-not-found errors.
class NotFoundExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final error = rawException.graphqlErrors[0];
    if (error.extensions?['code'] != 'NOT_FOUND_ERROR') return null;

    return AppError(
      AppErrorModel(
        message: error.message,
        code: 'NOT_FOUND_ERROR',
      ),
    );
  }
}

/// Handles validation errors, surfacing the first validation message.
class ValidationExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final error = rawException.graphqlErrors[0];
    if (error.extensions?['code'] != 'VALIDATION_ERROR') return null;

    final validationErrors = error.extensions?['validationErrors'] as List?;
    final message =
        validationErrors?.isNotEmpty == true
            ? validationErrors!.first['message'] as String? ?? error.message
            : error.message;

    return AppError(AppErrorModel(message: message, code: 'VALIDATION_ERROR'));
  }
}
