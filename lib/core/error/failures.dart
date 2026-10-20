import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Network connection error. Please check your internet connection.',
  ]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class ParsingFailure extends Failure {
  const ParsingFailure([
    super.message = 'Failed to parse response data correctly.',
  ]);
}

class CancelFailure extends Failure {
  const CancelFailure([super.message = 'Request was cancelled.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
