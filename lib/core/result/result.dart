sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data {
    if (this case Success<T>(:final data)) {
      return data;
    }
    return null;
  }

  String? get errorMessage {
    if (this case Failure<T>(:final message)) {
      return message;
    }
    return null;
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  @override
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.error]);

  final String message;
  final Object? error;
}
