import '../error/failures.dart';

sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(Failure failure) = ApiFailure<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  );

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull =>
      this is ApiSuccess<T> ? (this as ApiSuccess<T>).data : null;

  Failure? get failureOrNull =>
      this is ApiFailure<T> ? (this as ApiFailure<T>).failure : null;
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;

  const ApiSuccess(this.data);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return onSuccess(data);
  }
}

class ApiFailure<T> extends ApiResult<T> {
  final Failure failure;

  const ApiFailure(this.failure);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return onFailure(failure);
  }
}
