import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_auth_provider.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_parser.dart';
import 'package:graphql_infra_tool/interceptor/src/gql_interceptor.dart';

class GQLConfig {
  final String baseURL;
  final TokenCallback? bearerToken;
  final List<GQLAuthProvider>? authProviders;

  /// See [GQLExceptionParser] for implementation guidance.
  final List<GQLExceptionParser>? exceptionParsers;

  /// Interceptors to run on every request/response/error.
  ///
  /// Processed by [GQLInterceptorLink] which is inserted before all
  /// [AuthLink]s so retries pick up the freshly stored token. Interceptors
  /// execute in list order.
  ///
  /// Example — token refresh + cache:
  /// ```dart
  /// interceptors: [
  ///   GQLTokenRefreshInterceptor(provider: myRefreshProvider),
  ///   MyCacheInterceptor(),
  /// ]
  /// ```
  final List<GQLInterceptor>? interceptors;

  final Map<String, String>? defaultHeaders;
  final Store? cacheStore;
  final FetchPolicy? queryPolicy;
  final FetchPolicy? watchQueryPolicy;
  final FetchPolicy? mutationPolicy;
  final FetchPolicy? watchMutationPolicy;
  final FetchPolicy? subscribePolicy;
  final List<String>? responseNodePaths;

  /// Timeout for each HTTP request. Defaults to 30 seconds when not set.
  final Duration? connectionTimeout;

  GQLConfig({
    required this.baseURL,
    this.bearerToken,
    this.authProviders,
    this.exceptionParsers,
    this.interceptors,
    this.defaultHeaders,
    this.cacheStore,
    this.queryPolicy,
    this.watchQueryPolicy,
    this.mutationPolicy,
    this.watchMutationPolicy,
    this.subscribePolicy,
    this.responseNodePaths,
    this.connectionTimeout,
  });
}
