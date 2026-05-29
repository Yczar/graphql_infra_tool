import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

/// Project-level hook for converting raw link exceptions into [GQLException]s.
///
/// Parsers are called before the built-in
/// `OperationException.graphqlErrors` path. The first parser that returns a
/// non-null [GQLException] wins; returning `null` passes control to the next
/// parser (or the built-in fallback).
///
/// Example:
/// ```dart
/// class AcmeExceptionParser extends GQLExceptionParser {
///   @override
///   GQLException? parse(dynamic rawException) {
///     // only handle what we recognise; return null for everything else
///     if (rawException is! OperationException) return null;
///     final body = rawException.linkException;
///     if (body is! ServerException) return null;
///     // ... extract Acme-specific error shape from body.parsedResponse.data
///   }
/// }
/// ```
abstract class GQLExceptionParser {
  const GQLExceptionParser();
  GQLException? parse(dynamic rawException);
}
