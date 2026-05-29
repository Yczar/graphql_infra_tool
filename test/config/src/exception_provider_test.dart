import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';

void main() {
  group('GQLExceptionParser', () {
    test('should create custom exception for matching error code', () {
      final parser = TestExceptionParser();

      final exception = parser.parse(
        OperationException(
          graphqlErrors: [
            GraphQLError(
              message: 'Test error message',
              extensions: {'code': 'TEST_ERROR', 'status': 400},
            ),
          ],
        ),
      );

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Custom test error');
      expect(appError.errorModel.code, 'TEST_ERROR');
    });

    test('should return null for non-matching error code', () {
      final parser = TestExceptionParser();

      final exception = parser.parse(
        OperationException(
          graphqlErrors: [
            GraphQLError(
              message: 'Other error message',
              extensions: {'code': 'OTHER_ERROR'},
            ),
          ],
        ),
      );

      expect(exception, isNull);
    });

    test('should handle extensions data', () {
      final parser = StatusExceptionParser();

      final exception = parser.parse(
        OperationException(
          graphqlErrors: [
            GraphQLError(
              message: 'HTTP error occurred',
              extensions: {'code': 'HTTP_ERROR', 'status': 401},
            ),
          ],
        ),
      );

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Unauthorized access');
    });

    test('should return null for non-OperationException', () {
      final parser = TestExceptionParser();

      expect(parser.parse(Exception('raw error')), isNull);
      expect(parser.parse('some string'), isNull);
      expect(parser.parse(null), isNull);
    });
  });
}

// ── Test implementations ──────────────────────────────────────────────────────

class TestExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final error = rawException.graphqlErrors[0];
    final code = error.extensions?['code'] as String?;
    if (code != 'TEST_ERROR') return null;

    return AppError(AppErrorModel(message: 'Custom test error', code: code));
  }
}

class StatusExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;

    final error = rawException.graphqlErrors[0];
    final code = error.extensions?['code'] as String?;
    if (code != 'HTTP_ERROR') return null;

    final status = error.extensions?['status'] as int?;

    final message = switch (status) {
      401 => 'Unauthorized access',
      403 => 'Forbidden access',
      404 => 'Resource not found',
      _ => error.message,
    };

    return AppError(AppErrorModel(message: message, code: code));
  }
}
