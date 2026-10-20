class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class ParsingException implements Exception {
  final String message;

  const ParsingException(this.message);

  @override
  String toString() => 'ParsingException: $message';
}

class CancelException implements Exception {
  final String message;

  const CancelException(this.message);

  @override
  String toString() => 'CancelException: $message';
}
