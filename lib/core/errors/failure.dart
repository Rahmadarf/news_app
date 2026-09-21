/// Stable, testable failures exposed to state and presentation code.
///
/// Technical exceptions (`SocketException`, `TimeoutException`,
/// `FormatException`, HTTP status codes, storage errors) stay inside the data
/// layer and are mapped onto these types at the repository boundary.
///
/// Failures deliberately carry no localized UI copy. Presentation decides how
/// to word each case; [debugMessage] exists for logs and tests only.
sealed class Failure implements Exception {
  const Failure({this.debugMessage});

  /// Developer-facing detail. Never render this to end users.
  final String? debugMessage;

  @override
  String toString() => debugMessage == null
      ? runtimeType.toString()
      : '$runtimeType: $debugMessage';
}

/// Compile-time configuration is missing or invalid.
final class ConfigurationFailure extends Failure {
  const ConfigurationFailure({super.debugMessage});
}

/// The device could not reach the host at all.
final class NoConnectionFailure extends Failure {
  const NoConnectionFailure({super.debugMessage});
}

/// The request exceeded its deadline.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.debugMessage});
}

/// The API key is missing, invalid, or disabled. NewsAPI: 401.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.debugMessage});
}

/// Too many requests, or the daily quota is exhausted. NewsAPI: 429.
final class RateLimitedFailure extends Failure {
  const RateLimitedFailure({super.debugMessage});
}

/// The current plan does not allow this request. NewsAPI: 426.
final class UpgradeRequiredFailure extends Failure {
  const UpgradeRequiredFailure({super.debugMessage});
}

/// The server failed. NewsAPI: 5xx, or any unmapped non-2xx status.
final class ServerFailure extends Failure {
  const ServerFailure({required this.statusCode, super.debugMessage});

  final int statusCode;

  @override
  String toString() => 'ServerFailure($statusCode): $debugMessage';
}

/// The response arrived but could not be understood.
final class MalformedResponseFailure extends Failure {
  const MalformedResponseFailure({super.debugMessage});
}

/// Local storage could not be read or written.
final class CacheFailure extends Failure {
  const CacheFailure({super.debugMessage});
}

/// Anything not covered above.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage});
}
