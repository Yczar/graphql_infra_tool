## 1.1.0

### Added
* `GQLInterceptor` — abstract middleware hook with `onRequest`, `onResponse`, and `onError` lifecycle callbacks
* `GQLInterceptorLink` — a single `Link` that drives a list of `GQLInterceptor` instances, sitting before auth links so retries always pick up fresh tokens
* `GQLTokenRefreshProvider` — base class for implementing proactive and reactive token refresh strategies
* `GQLExceptionParser` — new pluggable extension point for project-level exception parsing; implement `parse(dynamic rawException)` and pass instances via `GQLConfig.exceptionParsers`
* `interceptors` field on `GQLConfig` to register custom `GQLInterceptor` instances
* `exceptionParsers` field on `GQLConfig` to register custom `GQLExceptionParser` instances

### Removed
* `GQLExceptionProvider` — replaced by the more flexible `GQLExceptionParser`. If you were using `GQLExceptionProvider`, migrate to `GQLExceptionParser` (see migration guide below)
* `exceptionProviders` field removed from `GQLConfig`

### Migration Guide

**Exception parsing — before:**
```dart
class MyExceptionProvider extends GQLExceptionProvider {
  @override
  String get errorCode => 'MY_ERROR';

  @override
  GQLException? createException(String errorCode, String? message, Map<String, dynamic>? extensions) {
    return AppError(AppErrorModel(message: message, code: errorCode));
  }
}

GQLConfig(
  baseURL: '...',
  exceptionProviders: [MyExceptionProvider()],
);
```

**Exception parsing — after:**
```dart
class MyExceptionParser extends GQLExceptionParser {
  @override
  GQLException? parse(dynamic rawException) {
    if (rawException is! OperationException) return null;
    if (rawException.graphqlErrors.isEmpty) return null;
    final error = rawException.graphqlErrors[0];
    if (error.extensions?['code'] != 'MY_ERROR') return null;
    return AppError(AppErrorModel(message: error.message, code: 'MY_ERROR'));
  }
}

GQLConfig(
  baseURL: '...',
  exceptionParsers: [MyExceptionParser()],
);
```

## 1.0.0

- Initial version.

## 1.0.1

### Added
* New unified `execute<T>()` method for all GraphQL operations
* New unified `executeList<T>()` method for list operations
* `OperationType` enum to specify query, mutation, or subscription

### Improved
* Reduced code duplication
* Better consistency across operations

### Breaking Changes
* `query<T>()` method - use `execute<T>()` with `OperationType.query`
* `mutate<T>()` method - use `execute<T>()` with `OperationType.mutation`
* `queryList<T>()` method - use `executeList<T>()` with `OperationType.query`
* `mutateList<T>()` method - use `executeList<T>()` with `OperationType.mutation`

### Migration Guide
```dart
// Before (still works but deprecated)
final user = await client.query<User>(...);

// After (recommended)
final user = await client.execute<User>(
  operation: getUserQuery,
  operationType: OperationType.query,
  variables: {'id': '123'},
  modelParser: (json) => User.fromJson(json),
);