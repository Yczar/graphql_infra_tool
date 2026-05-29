/// Value object returned by a successful token refresh operation.
class GQLRefreshResult {
  const GQLRefreshResult({
    required this.accessToken,
    this.refreshToken,
    this.expirationDate,
  });

  final String accessToken;
  final String? refreshToken;

  /// When the new access token expires. Used by [GQLTokenRefreshLink] for
  /// proactive refresh on the next request.
  final DateTime? expirationDate;
}

/// Contract that consumers must implement to enable automatic token refresh
/// inside [GQLTokenRefreshLink].
///
/// The four methods mirror the responsibilities split across
///   - [getTokenExpirationDate] — read from session storage
///   - [performRefresh] — make the actual network call to the auth service
///   - [onTokenRefreshed] — write the new tokens back to session storage so
///     that the [GQLAuthProvider.getToken] callback returns the updated value
///     on the next request in the chain.
abstract class GQLTokenRefreshProvider {
  Future<String?> getRefreshToken();
  Future<DateTime?> getTokenExpirationDate();
  Future<void> onTokenRefreshed(GQLRefreshResult result);
  Future<GQLRefreshResult?> performRefresh(String refreshToken);
}
