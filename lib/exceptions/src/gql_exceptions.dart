// ignore_for_file: deprecated_member_use_from_same_package

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_parser.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';

sealed class GQLException implements Exception {
  const GQLException();

  factory GQLException.fromException(
    dynamic exception, {
    List<GQLExceptionParser>? exceptionParsers,
  }) {
    
    // Project-level parsers
    if (exceptionParsers != null) {
      for (final parser in exceptionParsers) {
        final result = parser.parse(exception);
        if (result != null) return result;
      }
    }

    // Built-in paths
    if (exception is Exception) {
      if (exception is OperationException) {
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors[0];
          final errorMessage = graphqlError.message;
          final errorCode = graphqlError.extensions?['code'] ?? 'NO_CODE';
          final extensions = graphqlError.extensions;

          return AppError(
            AppErrorModel(
              message: errorMessage,
              code: errorCode,
              extensions: extensions,
            ),
          );
        }

        return AppError(AppErrorModel(message: 'Unknown GraphQL error'));
      } else if (exception is GQLException) {
        return exception;
      } else {
        return const UnExpectedError();
      }
    } else {
      if (exception is String && exception.contains('is not a subtype of')) {
        return const UnableToProcessError();
      }
      return const UnExpectedError();
    }
  }

  AppErrorModel get errorModel {
    return switch (this) {
      UnableToProcessError() => AppErrorModel(
        message: 'Unable to Process Data',
      ),
      UnExpectedError() => AppErrorModel(message: 'Unexpected Error occurred'),
      AppError(:final errorModel) => errorModel,
    };
  }
}

class UnableToProcessError extends GQLException {
  const UnableToProcessError();
}

class UnExpectedError extends GQLException {
  const UnExpectedError();
}

class AppError extends GQLException {
  @override
  final AppErrorModel errorModel;
  const AppError(this.errorModel);
}
