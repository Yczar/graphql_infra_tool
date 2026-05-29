import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/interceptor/src/gql_interceptor.dart';

/// A single GraphQL [Link] that drives a list of [GQLInterceptor]s through
/// their [GQLInterceptor.onRequest] → network → [GQLInterceptor.onResponse] /
/// [GQLInterceptor.onError] lifecycle.
///
/// **Execution order:**
/// - `onRequest` — interceptors run in list order (first → last)
/// - `onResponse` — interceptors run in list order on every response
/// - `onError` — interceptors run in list order; the first one that returns a
///   non-null [Response] resolves the error and stops further propagation
final class GQLInterceptorLink extends Link {
  const GQLInterceptorLink({required this.interceptors});

  final List<GQLInterceptor> interceptors;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    var currentRequest = request;

    // onRequest phase — each interceptor can modify the request in sequence.
    for (final interceptor in interceptors) {
      currentRequest = await interceptor.onRequest(currentRequest);
    }

    // The retry callback re-executes the downstream chain (AuthLink → HttpLink)
    // with a given request, returning the first response.
    Future<Response> retry(Request req) {
      return forward!(req).first;
    }

    try {
      await for (var response in forward!(currentRequest)) {
        // onResponse phase — each interceptor can transform or replace the response.
        for (final interceptor in interceptors) {
          response = await interceptor.onResponse(
            response,
            currentRequest,
            retry,
          );
        }
        yield response;
      }
    } catch (error, stackTrace) {
      // onError phase — first interceptor that returns a non-null Response wins.
      for (final interceptor in interceptors) {
        final recovery = await interceptor.onError(
          error,
          stackTrace,
          currentRequest,
          retry,
        );
        if (recovery != null) {
          yield recovery;
          return;
        }
      }
      rethrow;
    }
  }
}
