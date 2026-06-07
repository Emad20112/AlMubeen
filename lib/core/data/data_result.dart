import 'package:al_mubeen/core/data/data_failure.dart';

sealed class DataResult<T> {
  const DataResult();

  bool get isSuccess => this is DataSuccess<T>;

  bool get isFailure => this is DataError<T>;

  T? get valueOrNull {
    return switch (this) {
      DataSuccess<T>(:final value) => value,
      DataError<T>() => null,
    };
  }

  DataFailure? get failureOrNull {
    return switch (this) {
      DataSuccess<T>() => null,
      DataError<T>(:final failure) => failure,
    };
  }

  R when<R>({
    required R Function(T value) success,
    required R Function(DataFailure failure) error,
  }) {
    return switch (this) {
      DataSuccess<T>(:final value) => success(value),
      DataError<T>(:final failure) => error(failure),
    };
  }
}

final class DataSuccess<T> extends DataResult<T> {
  const DataSuccess(this.value);

  final T value;
}

final class DataError<T> extends DataResult<T> {
  const DataError(this.failure);

  final DataFailure failure;
}
