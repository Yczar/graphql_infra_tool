import 'package:graphql_flutter/graphql_flutter.dart';
///
/// Registered interceptors are run by [GQLInterceptorLink] in the order they
/// appear in [GQLConfig.interceptors].
abstract class GQLInterceptor {
  const GQLInterceptor();

  /// Called before the request is forwarded down the link chain.
  ///
  /// Return the (possibly modified) [Request] to continue normally.
  Future<Request> onRequest(Request request) async => request;

  /// Called for each [Response] that comes back from the network.
  ///
  /// The [retry] callback re-executes the downstream link chain
  /// with the given request — use it to replay a request after
  /// refreshing a token or updating headers.
  Future<Response> onResponse(
    Response response,
    Request request,
    Future<Response> Function(Request) retry,
  ) async => response;

  /// Called when the downstream chain throws an exception
  ///
  /// Return a [Response] to recover from the error, or return `null` to let
  /// the exception propagate to the next interceptor. The [retry] callback
  /// re-executes the downstream chain — use it after refreshing a token.
  Future<Response?> onError(
    Object error,
    StackTrace stackTrace,
    Request request,
    Future<Response> Function(Request) retry,
  ) async => null;
}
