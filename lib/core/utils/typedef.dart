import '../errors/failures.dart';

// Result type for handling success/failure states
class Result<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const Result._({this.data, this.failure, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(Failure failure) =>
      Result._(failure: failure, isSuccess: false);

  bool get isFailure => !isSuccess;
}

typedef ResultFuture<T> = Future<Result<T>>;
typedef ResultVoid = Future<Result<void>>;
typedef DataMap = Map<String, dynamic>;
